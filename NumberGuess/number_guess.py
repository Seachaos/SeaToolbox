import os
import random

LANG = ['DE', 'EN']   # 德英
# LANG = ['EN']         # 英
# LANG = ['DE']         # 德
digs = 4

NUMBER_RANGE = [str(i) for i in range(10)]
RAND_DIG = True

# define color code
BLUE = 34
GREEN = 32
RED = 31
YELLOW = 33
WHITE = 37

eng_voices = ['Daniel', 'Karen', 'Alex', 'Fred', 'Samantha', 'Victoria']

def say(msg, lang):
  if lang=='DE':
    cmd = 'say -v Anna'
  else:
    voice = random.choice(eng_voices)
    cmd = f'say -v {voice}'
  cmd = f'{cmd} "{msg}" &'
  os.system(cmd)

def msg(color, text):
  color = f"{color}m"
  print(f"\033[{color}{text}\033[00m")

while True:
  dlen = random.randint(1, digs) if RAND_DIG else dig
  num = ''.join([random.choice(NUMBER_RANGE) for i in range(dlen)])
  lang = random.choice(LANG)
  retry = 0
  while True:
    say(num, lang)
    msg(WHITE, 'INPUT NUMBER : ' if retry==0 else f'INPUT NUMBER : (try {retry})')
    ans = input()
    if ans.strip() in ['?', 'h']:
      msg(GREEN, num)
    elif ans == '':
      pass
    elif num.strip() == ans.strip():
      msg(YELLOW, 'correct')
      break
    else:
      msg(RED, 'try again')
    retry += 1