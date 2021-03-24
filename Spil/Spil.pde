Player player;

Point currentPoint;

ArrayList<Point> point;

int count;
int guess;
int result;
int level;

boolean pause;
boolean dead;

char[] operators;

void setup() {
  size(400, 400);
  
  textAlign(CENTER);
  textSize(20);

  player = new Player();
  level = 0;
  guess = 0;

  point = new ArrayList<Point>();
  point.add(new Point(level));

  currentPoint = point.get(0);
  result = currentPoint.result;
  point.remove(0);

  count = 0;
  pause = true;
  dead = false;

  operators = new char[4];
  operators[0] = '+';
  operators[1] = '-';
  operators[2] = '*';
  operators[3] = '/';
}

//------------------------------------------------------------------------------------------------------------- 

void draw() {

  if (dead) {
    background(200);
    endScreen(); // viser slut skærmen
  } else {
    if (pause) { // pauser spillet og viser regnestykket
      background(200);
      calculationScreen();
    } else { // Her er koden til selve spillet
      background(200);
      text(player.score, width*0.5, height*0.5); // Viser spillerens score
      player.update(); // updatere spilleren
      updatePoints(); // updatere pointene
      hit(); // Tjekker om spilleren rør et point    
      spawnPoint(); // spawner point
      level(); // ændre det level man spillet på
      if (player.hit()) {
        dead = true; // hvis spilleren bliver ramt af zombien så dør man
      }
    }
  }
  
}

//------------------------------------------------------------------------------------------------------------- 

void mousePressed() {
  if(pause && mouseX > width*0.5){
    guess++;
  }
  
  if(pause && mouseX < width*0.5){
    guess--;
  }
  
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
  text("Game Over!",width*0.5,height*0.5);
}

//-------------------------------------------------------------------------------------------------------------

void spawnPoint() {
  if (count > 300) {
    point.add(new Point(level));
    count = 0;
  } else {
    count++;
  }
}

//-------------------------------------------------------------------------------------------------------------

void keyPressed() {
  
  if(dead && key == ENTER){
    dead = false;
    frameCount = -1;
  }
  
  if(pause && keyCode == RIGHT){
    guess++;
  }
  
  if(pause && keyCode == LEFT){
    guess--;
  }
  
  if (pause && key == ENTER && guess == result) {
    guess = 0;
    player.score++;
    pause = false;
    if (player.zombie.limit>0) {
      player.zombie.limit -= 0.30;
    }
  } else if (pause && key == ENTER && guess != result) {
    guess = 0;
    player.score--;
    pause = false;
    player.zombie.limit += 0.1;
  }
}

//-------------------------------------------------------------------------------------------------------------

void level(){
  if(player.score<10){
    level = 0;
  } else if(player.score<25){
    level = 1;
  } else if(player.score<50){
    level = 2;
  } else {
    level = 3;
  }
}

//-------------------------------------------------------------------------------------------------------------

void calculationScreen(){
  rectMode(CORNER);
  noStroke();
  fill(255,0,0,150);
  rect(0,0,width*0.5,height);
  fill(0,255,0,150);
  rect(width*0.5,0,width*0.5,height);
  fill(0);
  stroke(0);
  text(currentPoint.valueOne + " " + operators[currentPoint.operator] + " " + currentPoint.valueTwo, width*0.5, height*0.25);
  text("Gæt: " + guess, width*0.5, height*0.5);
  text("+", width*0.75, height*0.5);
  text("-", width*0.25, height*0.5);
}

//-------------------------------------------------------------------------------------------------------------
