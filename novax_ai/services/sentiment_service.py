"""
sentiment_service.py
Service d'analyse de sentiment pour NovaX.
HANKPE Ulrich — Big Data & IA

Usage :
    python sentiment_service.py --text "Salut, ça va super bien !"
    python sentiment_service.py --text "Ce projet est nul"

Retourne :
    { "score": "positive|neutral|negative", "confidence": 0.95 }
"""

import argparse
import json
import os
import requests

# Charge la configuration
CONFIG_PATH = os.path.join(os.path.dirname(__file__), '..', 'config', 'vertex_ai_config.json')

def load_config():
    with open(CONFIG_PATH, 'r') as f:
        return json.load(f)

def analyze_sentiment(text: str, api_key: str = None) -> dict:
    """
    Analyse le sentiment d'un texte via Google Natural Language API.
    
    Args:
        text: Le texte à analyser
        api_key: Clé API Google Cloud (optionnel, utilise la config si absent)
    
    Returns:
        dict: { "score": "positive|neutral|negative", "confidence": float, "raw_score": float }
    """
    config = load_config()
    key = api_key or config.get('api_key', '')
    
    if not key:
        # Mode fallback : analyse locale par mots-clés
        return _analyze_locally(text)
    
    # Appel à l'API Google Natural Language
    url = f"{config['sentiment_endpoint']}?key={key}"
    
    payload = {
        "document": {
            "type": "PLAIN_TEXT",
            "content": text,
            "language": "fr"
        },
        "encodingType": "UTF8"
    }
    
    try:
        response = requests.post(url, json=payload, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        raw_score = data['documentSentiment']['score']
        magnitude = data['documentSentiment']['magnitude']
        
        # Interprétation du score
        thresholds = config.get('score_thresholds', {'positive': 0.25, 'negative': -0.25})
        
        if raw_score > thresholds['positive']:
            sentiment = 'positive'
        elif raw_score < thresholds['negative']:
            sentiment = 'negative'
        else:
            sentiment = 'neutral'
        
        return {
            "score": sentiment,
            "confidence": abs(raw_score),
            "magnitude": magnitude,
            "raw_score": raw_score
        }
        
    except Exception as e:
        print(f"[Sentiment] Erreur API: {e} — Fallback local")
        return _analyze_locally(text)


def _analyze_locally(text: str) -> dict:
    """
    Analyse locale par mots-clés (fallback sans API).
    Même logique que SentimentService.dart côté Flutter.
    """
    text_lower = text.lower()
    
    positive_words = [
        'super', 'bien', 'excellent', 'parfait', 'génial', 'bravo', 'merci',
        'top', 'cool', 'sympa', 'beau', 'belle', 'magnifique', 'formidable',
        'fantastique', 'incroyable', 'heureux', 'heureuse', 'content', 'joie',
        'amour', 'aimer', 'adorer', 'félicitations', 'oui', 'ok', 'accord',
        'avance', 'réussi', 'gagné', 'bonne', 'bon', 'great', 'good', 'nice'
    ]
    
    negative_words = [
        'non', 'pas', 'jamais', 'problème', 'erreur', 'bug', 'mauvais',
        'mauvaise', 'nul', 'nulle', 'horrible', 'terrible', 'catastrophe',
        'raté', 'échoué', 'impossible', 'difficile', 'triste', 'dommage',
        'désolé', 'désolée', 'excuse', 'pardon', 'énervé', 'fâché', 'colère',
        'frustré', 'déçu', 'déçue', 'fail', 'bad', 'wrong', 'no'
    ]
    
    pos_count = sum(1 for w in positive_words if w in text_lower)
    neg_count = sum(1 for w in negative_words if w in text_lower)
    
    if pos_count > neg_count:
        return {"score": "positive", "confidence": 0.7, "raw_score": 0.5}
    elif neg_count > pos_count:
        return {"score": "negative", "confidence": 0.7, "raw_score": -0.5}
    else:
        return {"score": "neutral", "confidence": 0.5, "raw_score": 0.0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Analyse de sentiment NovaX')
    parser.add_argument('--text', type=str, required=True, help='Texte à analyser')
    parser.add_argument('--key', type=str, help='Clé API Google Cloud (optionnel)')
    
    args = parser.parse_args()
    result = analyze_sentiment(args.text, args.key)
    
    print(json.dumps(result, ensure_ascii=False, indent=2))
