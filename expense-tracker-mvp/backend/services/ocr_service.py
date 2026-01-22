"""
OCR Service for extracting text from receipt images.

CURRENT IMPLEMENTATION: Mock OCR that returns sample receipt text.

TO INTEGRATE REAL OCR:
Replace the extract_text method with one of these options:
1. Google Cloud Vision API
2. AWS Textract
3. Tesseract OCR (open source)
4. Azure Computer Vision

Example with Google Cloud Vision:
    from google.cloud import vision
    client = vision.ImageAnnotatorClient()
    with open(image_path, 'rb') as image_file:
        content = image_file.read()
    image = vision.Image(content=content)
    response = client.text_detection(image=image)
    return response.text_annotations[0].description
"""

import random
from datetime import datetime, timedelta


class OCRService:
    """Service for extracting text from receipt images using OCR."""

    def __init__(self):
        """Initialize OCR service."""
        # In real implementation, initialize OCR client here
        # e.g., self.client = vision.ImageAnnotatorClient()
        pass

    def extract_text(self, image_path):
        """
        Extract text from receipt image.

        Args:
            image_path: Path to the receipt image file

        Returns:
            String containing extracted text from the receipt
        """
        # MOCK IMPLEMENTATION
        # This returns realistic sample receipt text
        # In production, replace this with actual OCR API call

        sample_stores = ['Walmart', 'Target', 'Whole Foods', 'Costco', 'Safeway']
        store = random.choice(sample_stores)

        # Generate random date within last 30 days
        days_ago = random.randint(0, 30)
        receipt_date = datetime.now() - timedelta(days=days_ago)
        date_str = receipt_date.strftime('%m/%d/%Y')

        # Generate sample items
        sample_items = [
            ('Organic Milk 1gal', random.uniform(4.5, 6.5)),
            ('Bread Whole Wheat', random.uniform(2.5, 4.0)),
            ('Eggs Large 12ct', random.uniform(3.0, 5.0)),
            ('Chicken Breast 2lb', random.uniform(8.0, 12.0)),
            ('Bananas 3lb', random.uniform(1.5, 3.0)),
            ('Tomatoes 2lb', random.uniform(3.0, 5.0)),
            ('Pasta 16oz', random.uniform(1.5, 3.0)),
            ('Laundry Detergent', random.uniform(8.0, 15.0)),
            ('Paper Towels 6pk', random.uniform(10.0, 15.0)),
            ('Orange Juice 64oz', random.uniform(4.0, 6.0)),
            ('Beer 6pk', random.uniform(8.0, 12.0)),
            ('Wine Bottle', random.uniform(10.0, 20.0)),
        ]

        # Select random items
        num_items = random.randint(4, 8)
        selected_items = random.sample(sample_items, num_items)

        # Build receipt text
        lines = [
            store,
            f"Date: {date_str}",
            "",
            "Items:"
        ]

        total = 0
        for item_name, price in selected_items:
            total += price
            lines.append(f"{item_name}    ${price:.2f}")

        lines.append("")
        lines.append(f"Subtotal: ${total:.2f}")
        lines.append(f"Tax: ${total * 0.08:.2f}")
        total_with_tax = total * 1.08
        lines.append(f"Total: ${total_with_tax:.2f}")
        lines.append("")
        lines.append("Thank you for shopping!")

        mock_text = "\n".join(lines)

        print(f"[OCR Mock] Extracted text from {image_path}")
        return mock_text

    def extract_text_real(self, image_path):
        """
        PLACEHOLDER for real OCR implementation.

        Uncomment and modify based on your chosen OCR service.
        """
        # Example: Google Cloud Vision
        # from google.cloud import vision
        # client = vision.ImageAnnotatorClient()
        #
        # with open(image_path, 'rb') as image_file:
        #     content = image_file.read()
        #
        # image = vision.Image(content=content)
        # response = client.text_detection(image=image)
        #
        # if response.error.message:
        #     raise Exception(f'OCR error: {response.error.message}')
        #
        # return response.text_annotations[0].description if response.text_annotations else ""

        # Example: Tesseract OCR (open source)
        # import pytesseract
        # from PIL import Image
        #
        # image = Image.open(image_path)
        # text = pytesseract.image_to_string(image)
        # return text

        raise NotImplementedError("Real OCR not implemented yet")
