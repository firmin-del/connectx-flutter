"""
sheets_pipeline.py
Pipeline Big Data → Google Sheets pour NovaX.
HANKPE Ulrich — Big Data & IA

Rôle : Recevoir les métadonnées anonymisées des messages
et les insérer dans Google Sheets pour le dashboard Looker Studio.

Usage :
    python sheets_pipeline.py --length 42 --sentiment positive --chat_hash 12345
"""

import argparse
import json
import os
import requests
from datetime import datetime

CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 'config', 'vertex_ai_config.json')

def load_config():
    with open(CONFIG_PATH, 'r') as f:
        return json.load(f)

def track_message(message_length: int, sentiment: str, chat_hash: str, api_key: str = None):
    """
    Envoie les métadonnées d'un message vers Google Sheets.
    
    Args:
        message_length : longueur du message en caractères
        sentiment      : "positive" | "neutral" | "negative"
        chat_hash      : hash anonymisé de l'ID du chat
        api_key        : clé API Google Cloud
    
    Données envoyées (JAMAIS le contenu du message) :
        [timestamp, longueur, sentiment, heure, jour_semaine, chat_hash]
    """
    config = load_config()
    key = api_key or config.get('api_key', '')
    sheets_id = config.get('google_sheets_id', '')
    sheets_range = config.get('google_sheets_range', 'Sheet1!A:F')
    
    now = datetime.now()
    
    # Ligne de données à insérer
    row = [
        now.isoformat(),           # A: Timestamp
        message_length,            # B: Longueur du message
        sentiment,                 # C: Score sentiment
        now.hour,                  # D: Heure de la journée
        now.weekday() + 1,         # E: Jour de la semaine (1=Lundi)
        chat_hash,                 # F: Hash anonymisé du chat
    ]
    
    if not key or not sheets_id:
        # Mode développement : log local
        print(f"[Pipeline] Données trackées (mode local) : {row}")
        return True
    
    # Appel à l'API Google Sheets
    url = f"https://sheets.googleapis.com/v4/spreadsheets/{sheets_id}/values/{sheets_range}:append"
    
    payload = {
        "values": [row],
        "majorDimension": "ROWS"
    }
    
    params = {
        "valueInputOption": "USER_ENTERED",
        "insertDataOption": "INSERT_ROWS",
        "key": key
    }
    
    try:
        response = requests.post(url, json=payload, params=params, timeout=10)
        response.raise_for_status()
        print(f"[Pipeline] ✅ Données envoyées vers Google Sheets")
        return True
    except Exception as e:
        print(f"[Pipeline] ❌ Erreur Google Sheets: {e}")
        return False


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Pipeline Big Data NovaX')
    parser.add_argument('--length', type=int, required=True)
    parser.add_argument('--sentiment', type=str, required=True,
                        choices=['positive', 'neutral', 'negative'])
    parser.add_argument('--chat_hash', type=str, required=True)
    parser.add_argument('--key', type=str, help='Clé API Google Cloud')
    
    args = parser.parse_args()
    track_message(args.length, args.sentiment, args.chat_hash, args.key)
