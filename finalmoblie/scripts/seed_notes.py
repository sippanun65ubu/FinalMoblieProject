import requests
from faker import Faker
import random

# ตั้งค่า PocketBase endpoint ของคุณ
POCKETBASE_URL = "http://127.0.0.1:8090/api/collections/notes/records"

fake = Faker()

# สี pastel สำหรับสุ่ม
colors = [
    "#FFF9C4",  # light yellow
    "#F8BBD0",  # pink
    "#C8E6C9",  # light green
    "#BBDEFB",  # light blue
    "#FFE0B2",  # peach
    "#E1BEE7",  # lavender
    "#B2EBF2",  # teal
]

def create_fake_note():
    """สร้าง note จำลอง 1 รายการ"""
    return {
        "title": fake.sentence(nb_words=4).rstrip("."),
        "content": fake.paragraph(nb_sentences=random.randint(2, 5)),
        "color": random.choice(colors),
    }

def main():
    total = 10  # จำนวน note ที่ต้องการสร้าง
    for i in range(total):
        note = create_fake_note()
        res = requests.post(POCKETBASE_URL, json=note)
        if res.status_code == 200:
            print(f"✅ Created note {i+1}: {note['title']}")
        else:
            print(f"❌ Error {res.status_code}: {res.text}")

if __name__ == "__main__":
    main()
