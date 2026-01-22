"""
AI Parser Service for converting OCR text to structured receipt data.

CURRENT IMPLEMENTATION: Rule-based parsing with simple categorization logic.

TO INTEGRATE REAL AI:
Replace the parse_receipt method with one of these options:
1. OpenAI GPT-4 API
2. Anthropic Claude API
3. Local LLM (e.g., Llama)
4. Custom trained model

Example with OpenAI:
    import openai
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{
            "role": "system",
            "content": "Parse this receipt text into JSON..."
        }, {
            "role": "user",
            "content": ocr_text
        }]
    )
    return json.loads(response.choices[0].message.content)
"""

import re
from datetime import datetime


class AIParser:
    """Service for parsing OCR text into structured receipt data using AI."""

    def __init__(self):
        """Initialize AI parser."""
        # In real implementation, initialize AI client here
        # e.g., self.client = openai.OpenAI(api_key="...")
        pass

    def parse_receipt(self, ocr_text):
        """
        Parse OCR text into structured receipt data.

        Args:
            ocr_text: Raw text extracted from receipt

        Returns:
            dict: Structured receipt data with format:
                {
                    "store": str,
                    "date": str (ISO format),
                    "items": [{"name": str, "price": str, "category": str}],
                    "total": str,
                    "currency": str
                }
        """
        # MOCK IMPLEMENTATION
        # This uses rule-based parsing for the mock OCR output
        # In production, replace with AI API call

        lines = ocr_text.strip().split('\n')

        # Extract store (first non-empty line)
        store = lines[0] if lines else "Unknown Store"

        # Extract date
        date_str = self._extract_date(ocr_text)

        # Extract currency
        currency = self._extract_currency(ocr_text)

        # Extract items
        items = self._extract_items(ocr_text)

        # Extract total
        total = self._extract_total(ocr_text)

        return {
            "store": store,
            "date": date_str,
            "items": items,
            "total": total,
            "currency": currency
        }

    def _extract_date(self, text):
        """Extract and parse date from receipt text."""
        # Look for date patterns
        date_pattern = r'Date:\s*(\d{1,2}/\d{1,2}/\d{4})'
        match = re.search(date_pattern, text)

        if match:
            date_str = match.group(1)
            try:
                # Convert to ISO format (YYYY-MM-DD)
                dt = datetime.strptime(date_str, '%m/%d/%Y')
                return dt.strftime('%Y-%m-%d')
            except ValueError:
                pass

        # Default to today if no date found
        return datetime.now().strftime('%Y-%m-%d')

    def _extract_items(self, text):
        """Extract line items from receipt text."""
        items = []

        # Look for lines with item name and price
        # Pattern: text followed by price in various formats:
        # $12.34, €12,34, 12.34, 12,34
        item_pattern = r'(.+?)\s+(?:[\$€£¥]?\s*)?(\d+[.,]\d{2})\s*(?:[\$€£¥])?'

        lines = text.split('\n')
        for line in lines:
            match = re.search(item_pattern, line)
            if match:
                item_name = match.group(1).strip()
                price = match.group(2)

                # Normalize price format (convert comma to dot)
                price = self._normalize_price(price)

                # Skip lines that are totals
                if any(keyword in item_name.lower() for keyword in ['subtotal', 'total', 'tax', 'suma', 'importe']):
                    continue

                # Categorize item
                category = self._categorize_item(item_name)

                items.append({
                    "name": item_name,
                    "price": price,
                    "category": category
                })

        return items

    def _extract_total(self, text):
        """Extract total amount from receipt."""
        # Look for total line in multiple formats
        # Patterns: Total: $12.34, TOTAL (€) 12,34, Total 12.34
        total_patterns = [
            r'[Tt][Oo][Tt][Aa][Ll]\s*(?:\([€\$£¥]\))?\s*(?:[€\$£¥])?\s*(\d+[.,]\d{2})',
            r'[Ss][Uu][Mm][Aa]\s*(?:\([€\$£¥]\))?\s*(?:[€\$£¥])?\s*(\d+[.,]\d{2})',
            r'[Ii][Mm][Pp][Oo][Rr][Tt][Ee]\s*(?:\([€\$£¥]\))?\s*(?:[€\$£¥])?\s*(\d+[.,]\d{2})',
        ]

        for pattern in total_patterns:
            match = re.search(pattern, text)
            if match:
                price = match.group(1)
                return self._normalize_price(price)

        return "0.00"

    def _normalize_price(self, price_str):
        """Normalize price format by converting comma to dot."""
        # Replace comma with dot for decimal separator
        return price_str.replace(',', '.')

    def _extract_currency(self, text):
        """Detect currency from receipt text."""
        # Check for currency symbols
        if '€' in text or 'EUR' in text.upper():
            return 'EUR'
        elif '£' in text or 'GBP' in text.upper():
            return 'GBP'
        elif '¥' in text or 'JPY' in text.upper() or 'CNY' in text.upper():
            return 'JPY'
        elif '$' in text:
            # Could be USD, CAD, AUD, etc. Default to USD
            return 'USD'

        # Default to EUR for comma-based decimal separators
        # (common in Europe)
        if re.search(r'\d+,\d{2}', text):
            return 'EUR'

        return 'USD'  # Default fallback

    def _categorize_item(self, item_name):
        """
        Categorize item based on name.

        Categories: groceries, household, alcohol, other
        """
        item_lower = item_name.lower()

        # Alcohol keywords
        alcohol_keywords = ['beer', 'wine', 'liquor', 'vodka', 'whiskey', 'rum', 'tequila']
        if any(keyword in item_lower for keyword in alcohol_keywords):
            return 'alcohol'

        # Household keywords
        household_keywords = ['detergent', 'paper', 'towel', 'soap', 'cleaner', 'tissue', 'trash', 'bag']
        if any(keyword in item_lower for keyword in household_keywords):
            return 'household'

        # Groceries (most food items)
        grocery_keywords = [
            'milk', 'bread', 'egg', 'chicken', 'beef', 'pork', 'fish',
            'banana', 'apple', 'orange', 'tomato', 'lettuce', 'carrot',
            'pasta', 'rice', 'cereal', 'cheese', 'yogurt', 'juice',
            'organic', 'fresh', 'frozen'
        ]
        if any(keyword in item_lower for keyword in grocery_keywords):
            return 'groceries'

        # Default to groceries for food-related stores
        return 'groceries'

    def parse_receipt_with_ai(self, ocr_text):
        """
        PLACEHOLDER for real AI implementation.

        Uncomment and modify based on your chosen AI service.
        """
        # Example: OpenAI GPT-4
        # import openai
        # import json
        #
        # prompt = f"""
        # Parse this receipt text into JSON format with this structure:
        # {{
        #     "store": "store name",
        #     "date": "YYYY-MM-DD",
        #     "items": [
        #         {{"name": "item name", "price": "0.00", "category": "groceries|household|alcohol|other"}}
        #     ],
        #     "total": "0.00"
        # }}
        #
        # Receipt text:
        # {ocr_text}
        #
        # Return only the JSON, no additional text.
        # """
        #
        # response = openai.ChatCompletion.create(
        #     model="gpt-4",
        #     messages=[
        #         {"role": "system", "content": "You are a receipt parsing assistant. Return only valid JSON."},
        #         {"role": "user", "content": prompt}
        #     ],
        #     temperature=0.1
        # )
        #
        # result = response.choices[0].message.content
        # return json.loads(result)

        # Example: Anthropic Claude
        # import anthropic
        # import json
        #
        # client = anthropic.Anthropic(api_key="...")
        # message = client.messages.create(
        #     model="claude-3-5-sonnet-20241022",
        #     max_tokens=1024,
        #     messages=[{
        #         "role": "user",
        #         "content": f"Parse this receipt into JSON: {ocr_text}"
        #     }]
        # )
        # return json.loads(message.content[0].text)

        raise NotImplementedError("Real AI parsing not implemented yet")
