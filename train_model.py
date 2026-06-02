import cv2
import mediapipe as mp
import csv
import os
import time

# ── Signs to collect ──────────────────────────────────────────────────────────
SIGNS = [
    'HELLO',
    'HELP',
    'YES',
    'NO',
    'STOP',
    'THANK YOU',
    'SORRY',
    'PLEASE',
    'background'
]

SAMPLES_PER_SIGN = 200      # how many frames to record per sign
CSV_FILE         = 'hand_data.csv'

# ── MediaPipe setup ───────────────────────────────────────────────────────────
mp_hands   = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
hands      = mp_hands.Hands(static_image_mode=False,
                             max_num_hands=1,
                             min_detection_confidence=0.7)

# ── Helpers ───────────────────────────────────────────────────────────────────
def extract_landmarks(hand_landmarks):
    """Return flat list of 63 normalised (x, y, z) values."""
    return [coord
            for lm in hand_landmarks.landmark
            for coord in (lm.x, lm.y, lm.z)]

def draw_ui(frame, sign_name, sign_idx, collected, total,
            recording, countdown):
    h, w = frame.shape[:2]

    # Semi-transparent top bar
    overlay = frame.copy()
    cv2.rectangle(overlay, (0, 0), (w, 90), (0, 0, 0), -1)
    cv2.addWeighted(overlay, 0.55, frame, 0.45, 0, frame)

    # Sign name & progress
    cv2.putText(frame, f'Sign: {sign_name}  ({sign_idx+1}/{len(SIGNS)})',
                (12, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
    bar_w = int((collected / total) * (w - 24))
    cv2.rectangle(frame, (12, 50), (w - 12, 75), (60, 60, 60), -1)
    cv2.rectangle(frame, (12, 50), (12 + bar_w, 75), (0, 220, 100), -1)
    cv2.putText(frame, f'{collected}/{total}',
                (12, 70), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255, 255, 255), 1)

    # State label
    if countdown > 0:
        cv2.putText(frame, f'GET READY: {countdown}',
                    (w//2 - 120, h//2), cv2.FONT_HERSHEY_SIMPLEX,
                    1.6, (0, 200, 255), 3)
    elif recording:
        cv2.circle(frame, (w - 28, 28), 14, (0, 0, 230), -1)   # red dot
        cv2.putText(frame, 'REC', (w - 75, 35),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 230), 2)
    else:
        cv2.putText(frame, "Press SPACE to start  |  Q to quit",
                    (12, h - 16), cv2.FONT_HERSHEY_SIMPLEX,
                    0.6, (180, 180, 180), 1)

def collect_sign(cap, sign_name, sign_idx, csv_writer):
    """Collect SAMPLES_PER_SIGN frames for one sign. Returns False if user quits."""
    collected  = 0
    recording  = False
    countdown  = 0
    cd_start   = 0

    while True:
        ok, frame = cap.read()
        if not ok:
            print("⚠️  Camera read failed.")
            return False

        frame = cv2.flip(frame, 1)
        rgb   = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        res   = hands.process(rgb)

        # Draw hand skeleton
        if res.multi_hand_landmarks:
            for hl in res.multi_hand_landmarks:
                mp_drawing.draw_landmarks(frame, hl,
                                          mp_hands.HAND_CONNECTIONS)

        # Countdown logic
        if countdown > 0:
            elapsed  = time.time() - cd_start
            remaining = 3 - int(elapsed)
            if remaining <= 0:
                countdown = 0
                recording = True
            else:
                countdown = remaining

        # Record landmark while recording
        if recording and res.multi_hand_landmarks:
            lm = extract_landmarks(res.multi_hand_landmarks[0])
            csv_writer.writerow([sign_idx] + lm)
            collected += 1
            if collected >= SAMPLES_PER_SIGN:
                recording = False
                return True          # done with this sign

        draw_ui(frame, sign_name, sign_idx, collected,
                SAMPLES_PER_SIGN, recording, countdown)
        cv2.imshow('Data Collector', frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            return False
        if key == ord(' ') and not recording and countdown == 0:
            countdown = 3
            cd_start  = time.time()

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("❌  Cannot open camera.")
        return

    # Append or create CSV
    file_exists = os.path.exists(CSV_FILE)
    csv_file    = open(CSV_FILE, 'a', newline='')
    writer      = csv.writer(csv_file)

    print(f"\n{'='*50}")
    print(f"  Sign Language Data Collector")
    print(f"  Collecting {SAMPLES_PER_SIGN} samples × {len(SIGNS)} signs")
    print(f"  Output → {CSV_FILE}")
    print(f"{'='*50}")
    print("  SPACE = start recording   Q = quit\n")

    for idx, sign in enumerate(SIGNS):
        print(f"▶  Next sign: {sign}  ({idx+1}/{len(SIGNS)})")
        ok = collect_sign(cap, sign, idx, writer)
        csv_file.flush()
        if not ok:
            print("⚠️  Collection stopped early.")
            break
        print(f"✅  {sign} done!\n")

    cap.release()
    csv_file.close()
    cv2.destroyAllWindows()
    print(f"\n✅ Data saved to '{CSV_FILE}'")
    print("   Run your training script now!")

if __name__ == '__main__':
    main()