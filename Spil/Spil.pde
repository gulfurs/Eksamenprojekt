Player player;

Point currentPoint;

ArrayList<Point> point;

int count;

int result;

boolean pause;

char[] operators;

void setup() {
  size(400, 400);
  player = new Player();
  point = new ArrayList<Point>();
  point.add(new Point());
  currentPoint = point.get(0);
  count = 0;
  result = currentPoint.result;
  pause = true;
  operators = new char[4];
  operators[0] = '+';
  operators[1] = '-';
  operators[2] = '*';
  operators[3] = '/';
}

//------------------------------------------------------------------------------------------------------------- 

void draw() {


  if (pause) {
    background(200);
    text(currentPoint.valueOne + " " + operators[currentPoint.operator] + " " + currentPoint.valueTwo, width*0.5, height*0.5);
  } else {
    background(200);
    text(player.score, width*0.5, height*0.5);
    player.update();
    updatePoints();
    hit(); // Tjekker om spilleren rør et point    
    endScreen();
    spawnPoint();
  }



  /*
  if(//rammer et point){
   // regestykke kommer frem
   } else if (// spillet er slut){
   // slut skærm
   } else {
   // normale spil funktioner
   }
   */
}

//------------------------------------------------------------------------------------------------------------- 

void mousePressed() {
}

//------------------------------------------------------------------------------------------------------------- 

void hit() {
  for (int i = 0; i < point.size(); i++ ) {
    float d = dist(player.pos.x, player.pos.y, point.get(i).pos.x, point.get(i).pos.y);
    if (d<(point.get(i).size+player.size)*0.5) {
      pause = !pause;
      currentPoint = point.get(i);
      result = point.get(i).result;
      point.remove(i);
    }
  }
}

//------------------------------------------------------------------------------------------------------------- 

void updatePoints() {
  for (int i = 0; i < point.size(); i++ ) {
    point.get(i).update();
  }
}

//------------------------------------------------------------------------------------------------------------- 

void endScreen() {
  if (player.hit()) {
    frameCount = -1;
  }
}

//-------------------------------------------------------------------------------------------------------------

void spawnPoint() {
  if (count > 300) {
    point.add(new Point());
    count = 0;
  } else {
    count++;
  }
}

//-------------------------------------------------------------------------------------------------------------

void keyPressed() {
  if (pause && (int)key-48==result) {
    player.score++;
    pause = false;
    if (player.zombie.limit>0) {
      player.zombie.limit -= 0.4;
    }
  } else if (pause && (int)key-48!=result){
    player.score--;
    pause = false;
    player.zombie.limit += 0.2;
  }
}

//-------------------------------------------------------------------------------------------------------------
