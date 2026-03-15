import cv2
import mediapipe as mp
import csv

# Setup MediaPipe hands
mp_hands = mp.solutions.hands
mp_draw = mp.solutions.drawing_utils
detector = mp_hands.Hands(
    max_num_hands=1,
    min_detection_confidence=0.7
)

# Your signs list — add more later!
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

SAMPLES_PER_SIGN = 100

# Create CSV
csv_file = open('hand_data.csv', 'w', newline='')
writer = csv.writer(csv_file)

current_idx = 0
sample_count = 0
collecting = False

cap = cv2.VideoCapture(0)

print(f"\n▶️  Ready! First sign: {SIGNS[current_idx]}")
print("SPACE = start/stop collecting")
print("N     = next sign")
print("Q     = quit\n")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    result = detector.process(rgb)

    landmarks_data = None

    if result.multi_hand_landmarks:
        for hand_lm in result.multi_hand_landmarks:
            mp_draw.draw_landmarks(
                frame, hand_lm, mp_hands.HAND_CONNECTIONS)

            # Extract 21 x,y,z = 63 values
            data = []
            for lm in hand_lm.landmark:
                data.extend([lm.x, lm.y, lm.z])
            landmarks_data = data

        # Save if collecting
        if collecting and landmarks_data:
            if sample_count < SAMPLES_PER_SIGN:
                writer.writerow([current_idx] + landmarks_data)
                sample_count += 1

    # Display on screen
    sign = SIGNS[current_idx]
    status = f"COLLECTING {sample_count}/{SAMPLES_PER_SIGN}" if collecting else "PRESS SPACE TO START"
    color = (0, 255, 0) if collecting else (0, 0, 255)

    cv2.putText(frame, f"Sign: {sign}", (10, 40),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 0), 2)
    cv2.putText(frame, status, (10, 85),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
    cv2.putText(frame, f"Sign {current_idx+1} of {len(SIGNS)}", (10, 125),
                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 1)

    # Done with this sign
    if sample_count >= SAMPLES_PER_SIGN and collecting:
        cv2.putText(frame, "DONE! Press N for next", (10, 165),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
        collecting = False

    cv2.imshow('Levora — Collect Signs', frame)

    key = cv2.waitKey(1) & 0xFF

    if key == ord(' '):
        if sample_count < SAMPLES_PER_SIGN:
            collecting = not collecting

    elif key == ord('n'):
        if sample_count >= SAMPLES_PER_SIGN:
            current_idx += 1
            sample_count = 0
            collecting = False
            if current_idx >= len(SIGNS):
                print("\n✅ All signs collected!")
                break
            print(f"▶️  Next sign: {SIGNS[current_idx]}")
        else:
            print(f"⚠️  Need {SAMPLES_PER_SIGN - sample_count} more samples!")

    elif key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
csv_file.close()
print("✅ Data saved to hand_data.csv!")