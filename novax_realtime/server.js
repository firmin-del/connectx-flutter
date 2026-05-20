/**
 * server.js
 * Serveur Socket.io temps réel pour NovaX
 * MIWANOU Michaël — RSI
 *
 * Rôle : Relayer les messages entre les clients Flutter en temps réel.
 * Le serveur ne stocke PAS les messages (c'est le rôle de Laravel/MySQL).
 * Il gère uniquement les connexions WebSocket persistantes.
 *
 * Lancer : node server.js
 * Port   : 3000
 */

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const config = require('./config/socket_config.json');

const app = express();
const server = http.createServer(app);

// ── Configuration Socket.io ────────────────────────────────────
const io = new Server(server, {
  cors: {
    origin: config.cors_origins,
    methods: ['GET', 'POST'],
    credentials: true,
  },
  transports: ['websocket', 'polling'],
});

// ── Stockage en mémoire des connexions actives ─────────────────
// Map : userId → socketId (pour savoir qui est en ligne)
const onlineUsers = new Map();

// ── Middleware d'authentification JWT ─────────────────────────
// Vérifie le token JWT envoyé par Flutter dans setAuth({'token': token})
io.use((socket, next) => {
  const token = socket.handshake.auth?.token;

  if (!token) {
    // Pas de token → connexion refusée
    return next(new Error('Token manquant'));
  }

  try {
    // Vérifie le token avec le même secret que Laravel
    const decoded = jwt.verify(token, config.jwt_secret);
    socket.userId = decoded.sub || decoded.id; // ID de l'utilisateur
    next(); // Connexion autorisée
  } catch (err) {
    next(new Error('Token invalide'));
  }
});

// ── Gestion des connexions ─────────────────────────────────────
io.on('connection', (socket) => {
  const userId = socket.userId;
  console.log(`[Socket] ✅ Connecté : userId=${userId}, socketId=${socket.id}`);

  // Enregistre l'utilisateur comme en ligne
  onlineUsers.set(userId, socket.id);

  // Notifie tous les autres utilisateurs que cet utilisateur est en ligne
  socket.broadcast.emit('user_online', userId);

  // ── Rejoindre une room de chat ─────────────────────────────
  // Flutter appelle joinChat(chatId) quand on ouvre une conversation
  socket.on('join_chat', ({ chat_id }) => {
    socket.join(`chat_${chat_id}`);
    console.log(`[Socket] userId=${userId} a rejoint chat_${chat_id}`);
  });

  // ── Quitter une room de chat ───────────────────────────────
  socket.on('leave_chat', ({ chat_id }) => {
    socket.leave(`chat_${chat_id}`);
    console.log(`[Socket] userId=${userId} a quitté chat_${chat_id}`);
  });

  // ── Envoi d'un message ─────────────────────────────────────
  // Flutter émet 'send_message' → on relaie à tous les participants du chat
  socket.on('send_message', (messageData) => {
    const { chat_id } = messageData;
    console.log(`[Socket] Message dans chat_${chat_id} de userId=${userId}`);

    // Relaie le message à tous les membres du chat (sauf l'expéditeur)
    socket.to(`chat_${chat_id}`).emit('new_message', messageData);
  });

  // ── Indicateur "en train d'écrire" ────────────────────────
  socket.on('typing', ({ chat_id }) => {
    // Notifie les autres membres du chat
    socket.to(`chat_${chat_id}`).emit('typing', chat_id);
  });

  socket.on('stop_typing', ({ chat_id }) => {
    socket.to(`chat_${chat_id}`).emit('stop_typing', chat_id);
  });

  // ── Accusé de lecture ──────────────────────────────────────
  // Flutter émet quand l'utilisateur lit un message (coches bleues)
  socket.on('message_read', ({ chat_id, message_id }) => {
    socket.to(`chat_${chat_id}`).emit('message_read', {
      chat_id,
      message_id,
    });
  });

  // ── Déconnexion ────────────────────────────────────────────
  socket.on('disconnect', () => {
    console.log(`[Socket] ❌ Déconnecté : userId=${userId}`);

    // Retire l'utilisateur de la liste en ligne
    onlineUsers.delete(userId);

    // Notifie les autres utilisateurs
    socket.broadcast.emit('user_offline', userId);
  });
});

// ── Route de santé (health check) ─────────────────────────────
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    online_users: onlineUsers.size,
    uptime: process.uptime(),
  });
});

// ── Démarrage du serveur ───────────────────────────────────────
server.listen(config.port, () => {
  console.log(`[NovaX Realtime] 🚀 Serveur Socket.io démarré sur le port ${config.port}`);
  console.log(`[NovaX Realtime] Health check : http://localhost:${config.port}/health`);
});
