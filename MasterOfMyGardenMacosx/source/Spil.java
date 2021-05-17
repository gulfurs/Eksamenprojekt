import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Spil extends PApplet {


Player player; // Spilleren

Point currentPoint; // Pointet/regnestykket man er i gang med at løse

SoundFile ding;
SoundFile buzz;

ArrayList<Point> point; // Liste over de point/regnestykker der er på banen

PImage lakeImage;
PImage background;
PImage pointImage;
PImage playerImage;
PImage[] startImage;

int count; // Bliver brugt til at spawne regnestykker
int guess; // Det tal man gætter på når man skal regne et regnestykke
int result; // Resultatet af regnestykket
int level; // Det level man er på(+, -, * eller /)
int breakTime; // Pausetiden (ca. 10 sek)
int lakeSize; // Størrelsen af søen

float wrongAnswerRate;

boolean pause; // Bestemmer om der er pause fra spillet
boolean dead; // Bestemmer om man er død
boolean inGame; // Bestemmer om man er i gang med spillet
boolean startScreen;

char[] operators; // +, -, * eller /

PVector lake;
PVector axisX;

public void setup() {
   // Størrelsen af vinduet

  textAlign(CENTER, CENTER);
  textSize(20); // Størrelse af teksten

  imageMode(CENTER);

  startImage = new PImage[3];  

  lakeImage = loadImage("data/Lake.png");
  background = loadImage("data/Background.png");
  pointImage = loadImage("data/Point.png");
  playerImage = loadImage("data/Player.png");
  startImage[0] = loadImage("data/StartScreen.png");
  startImage[1] = loadImage("data/StartScreenExit.png");
  startImage[2] = loadImage("data/StartScreenPlay.png");

  ding = new SoundFile(this, "data/Ding.mp3");
  buzz = new SoundFile(this, "data/Buzz.mp3");
  ding.amp(0.8f);
  buzz.amp(0.8f);

  player = new Player(); // Initialisering af spilleren
  level = 0; // Nulstil level
  guess = 0; // Nulstil guess
  count = 0; // Nulstil count
  wrongAnswerRate = 1.0f;

  lake = new PVector(player.zombie.pos.x, player.zombie.pos.y);
  axisX = new PVector(1, 0);

  point = new ArrayList<Point>(); // Initialisering af point listen
  point.add(new Point(level)); // Tilføjelse af point/regnestykke til listen

  breakTime = 1000; // Initialisering af breakTime til 1000 

  lakeSize = (int)random((width+height)*0.125f, (width+height)*0.35f);
  lakeImage.resize(lakeSize, lakeSize);
  
  for(int i = 0;i< startImage.length;i++){
    startImage[i].resize(width, height);
  }

  pause = false; 
  inGame = true;
  dead = false;
  startScreen = true;

  operators = new char[4]; // Initialisering af de fire forskellige operators
  operators[0] = '+';
  operators[1] = '-';
  operators[2] = '*';
  operators[3] = '/';

  doNotMove();
}

//------------------------------------------------------------------------------------------------------------- 

public void draw() {
  if (!startScreen) {
    if (dead) {                   // Hvis spilleren er død
      endScreen();                // Viser slut skærmen
    } else {                      // Hvis spilleren er i live
      if (pause) {        
        if (inGame) {             // Hvis man er inden i spillet
          calculationScreen();
        } else {                  // pause skærm
          pauseScreen();
        }

        breakTime--;              // Nedsætting af pausetid

        countDown();              // Viser nedtæller

        if (breakTime<0) {
          doNotMove();
          if (pause && inGame) {
            player.score--;
          }
          pause = false;
          inGame = true;
          breakTime = 1000;
          guess = 0;
        }
      } else {           // Her er koden til ingame i spillet
        image(background, width*0.5f, height*0.5f); // Sætter baggrund
        slowZone();
        fill(200);
        textSize(PApplet.parseInt((width+height)*0.0625f));
        text(player.score, width*0.5f, height*0.8f, 100); // Viser spillerens score
        player.update(); // updaterer spilleren
        updatePoints();  // updaterer pointene
        hit();           // Tjekker om spilleren rør et point    
        spawnPoint();    // spawner point
        level();         // ændre det level man spillet på
        if (player.hit()) {
          dead = true;   // hvis spilleren bliver ramt af zombien så dør man
        }
      }
    }
  } else {
    startScreen();
  }
}

//------------------------------------------------------------------------------------------------------------- 

public void mousePressed() {  
  if (startScreen && mouseX > PApplet.parseInt((width+height)*0.140625f) && mouseX < PApplet.parseInt((width+height)*0.365625f) && mouseY > PApplet.parseInt((width+height)*0.34375f) && mouseY < PApplet.parseInt((width+height)*0.375f)) {
    exit();
  } else if(startScreen && mouseX > PApplet.parseInt((width+height)*0.15625f) && mouseX < PApplet.parseInt((width+height)*0.353125f) && mouseY > PApplet.parseInt((width+height)*0.15625f) && mouseY < PApplet.parseInt((width+height)*0.1875f)){
    startScreen = false;
  }
  
  if (dead) {
    frameCount = -1;
  }

  if (inGame) { // Hvis man er inde i spillet
    if (pause && (mouseX>width*1/3 && mouseX<width*2/3 && mouseY>height*4/6 && mouseY<height*5/6)) { // Hvis det klikkes på den blå firkant
      checkGuessAndResult();
      guess = 0; // Nulstil guess
      pause = false; // Pausen sutter
      breakTime = 1000;
    }

    if (pause && mouseX > width*0.5f) { // Hvis pause of klik til højre
      guess++; // guess forøges med 1
    }

    if (pause && mouseX < width*0.5f) { // Hvis pause og klik til venstre
      guess--; // guess formindskes med 1
    }
  }
  doNotMove();
}

//------------------------------------------------------------------------------------------------------------- 

public void hit() { 
  for (int i = 0; i < point.size(); i++ ) { // Looper gennem alle point/regnestykker
    float d = dist(player.pos.x, player.pos.y, point.get(i).pos.x, point.get(i).pos.y); // Afstanden mellem point og spilleren
    if (d<(point.get(i).size+player.size)*0.5f) { // Hvis afstanden er mindre end deres radius
      pause = true; // Spillet pauses
      breakTime = 1000; // breakTime sættes
      currentPoint = point.get(i); // currentPoint sættes til det point man har ramt
      result = point.get(i).result; // resultatet beregnes for det point/regnestykke man har ramt
      point.remove(i); // pointet/regnestykket fjernes fra banen(så man ikke kan ramme det flere gange)
    }
  }
}

//------------------------------------------------------------------------------------------------------------- 

public void updatePoints() {
  for (int i = 0; i < point.size(); i++ ) { // Looper gennem alle point/regnestykker
    point.get(i).update(); // alle point/regnestykker opdateres
  }
}

//------------------------------------------------------------------------------------------------------------- 

public void endScreen() {
  textSize(PApplet.parseInt((width+height)*0.04375f));
  text("Game Over", width*0.5f, height*0.5f); // Skriver "Game Over!" midt på skærmen
  textSize(PApplet.parseInt((width+height)*0.0125f));
  text("Tryk 'r', ENTER eller på skærmen for at genstarte spillet", width*0.5f, height*0.6f);
}

//-------------------------------------------------------------------------------------------------------------

public void spawnPoint() {
  if (count > 200) { // Count større end 300
    point.add(new Point(level)); // Tilføjelse af nyt point/regnestykke til listen
    count = 0; // count nulstilles
  } else {
    count++; // count forøges med 1
  }
}

//-------------------------------------------------------------------------------------------------------------

public void keyPressed() {
  startScreen = false;
  doNotMove();

  if (key == 'p' || key == 'P') { // Der trykkes på p og Spillet pauses
    if (pause && !inGame) { // Hvis man allerede er på pause
      breakTime = 5;
    } else if (!pause && inGame) {
      pause = true;
      inGame = false;
    }
  } 

  if (dead && key == ENTER || key == 'r' || key == 'R') {
    dead = false;
    frameCount = -1;
  }

  if (inGame) {
    if (pause && keyCode == RIGHT) {
      guess++;
    }

    if (pause && keyCode == LEFT) {
      guess--;
    }

    if (key == ENTER && pause) {
      checkGuessAndResult();
      doNotMove();
      pause = false;
      guess = 0;
      breakTime = 1000;
    }
  }
}

//-------------------------------------------------------------------------------------------------------------

public void level() {
  if (player.score<10) {
    level = 0;
  } else if (player.score<25) {
    level = 1;
  } else if (player.score<50) {
    level = 2;
  } else {
    level = 3;
  }
}

//-------------------------------------------------------------------------------------------------------------

public void calculationScreen() {
  ding.stop();
  buzz.stop();

  rectMode(CORNER);
  noStroke();

  //Rød firkant
  fill(255, 0, 0, 150);
  rect(0, 0, width*0.5f, height);

  //Grøn firkant
  fill(0, 255, 0, 150);
  rect(width*0.5f, 0, width*0.5f, height);

  //Blå firkant
  fill(0, 0, 255, 150);
  rect(width*1/3, height*4/6, width*1/3, height*1/6);

  //Hvid firkant
  fill(255);
  rect(width*1/3, height*1/6, width*1/3, height*1/6);

  fill(0); //Tilbage til sort
  stroke(0);
  textSize((width+height)*0.025f);
  text(currentPoint.valueOne + " " + operators[currentPoint.operator] + " " + currentPoint.valueTwo, width*0.5f, height*3/12);
  text("Gæt: " + guess, width*0.5f, height*0.5f);
  text("+", width*0.75f, height*0.5f);
  text("-", width*0.25f, height*0.5f);
  text("Enter", width*0.5f, height*9/12);
  textSize((width+height)*0.008f);
  text("(→)", width*0.75f, height*0.55f);
  text("(←)", width*0.25f, height*0.55f);
}

//-------------------------------------------------------------------------------------------------------------

public void slowZone() {
  float distPlayer = dist(lake.x, lake.y, player.pos.x, player.pos.y);
  float distZombie = dist(lake.x, lake.y, player.zombie.pos.x, player.zombie.pos.y);
  image(lakeImage, lake.x, lake.y);
  if (distPlayer < lakeSize*0.5f + player.size*0.5f) {
    player.inMud = true;
  } else {
    player.inMud = false;
  } 

  if (distZombie < lakeSize*0.5f + player.zombie.size*0.5f) {
    player.zombie.inMud = true;
  } else {
    player.zombie.inMud = false;
  }
}

//-------------------------------------------------------------------------------------------------------------

public void startScreen() {
  if (startScreen && mouseX > PApplet.parseInt((width+height)*0.140625f) && mouseX < PApplet.parseInt((width+height)*0.365625f) && mouseY > PApplet.parseInt((width+height)*0.34375f) && mouseY < PApplet.parseInt((width+height)*0.375f)) { 
    background(startImage[1]);
  } else if(startScreen && mouseX > PApplet.parseInt((width+height)*0.15625f) && mouseX < PApplet.parseInt((width+height)*0.353125f) && mouseY > PApplet.parseInt((width+height)*0.15625f) && mouseY < PApplet.parseInt((width+height)*0.1875f)){
    background(startImage[2]);
  } else {
    background(startImage[0]);
  }
}

//-------------------------------------------------------------------------------------------------------------

public void pauseScreen() {
  image(background, width*0.5f, height*0.5f); // Sætter baggrund
  slowZone(); // viser søen
  player.display(); // Viser spilleren
  player.zombie.display(); // Viser zombien
  updatePoints();  // Updaterer pointene
  textSize(PApplet.parseInt((width+height)*0.0625f));
  text("Pause", width*0.5f, height*0.2f); // Viser spillerens score
  textSize(PApplet.parseInt((width+height)*0.01875f));
  text("Din score er: " + player.score, width*0.5f, height*0.5f); // Viser spillerens score
  text("Du er på level: " + PApplet.parseInt(level+1), width*0.5f, height*0.7f); // Viser spillerens level
  textSize(PApplet.parseInt((width+height)*0.0125f));
  text("Tryk 'p' for at afslutte pausen", width*0.5f, height*0.3f);
  text("Tryk 'r' for at genstarte spillet", width*0.5f, height*0.8f);
}

//-------------------------------------------------------------------------------------------------------------

public void checkGuessAndResult() {
  if (guess == result) {
    ding.play();
    player.score++;
    player.zombie.noLimit *= 0.70f;
  } else if (guess != result) {
    buzz.play();
    wrongAnswerRate += 0.05f;
    player.score--;
    player.zombie.noLimit *= wrongAnswerRate;
  }
}

//-------------------------------------------------------------------------------------------------------------

public void doNotMove() {
  mouseX = (int)player.pos.x; // Så bevæger man sig ikke 
  mouseY = (int)player.pos.y; // Så bevæger man sig ikke 
}

//-------------------------------------------------------------------------------------------------------------

public void countDown() {
  noStroke();
  fill(255);
  rectMode(CENTER);
  rect(width*0.9f, height*0.905f, PApplet.parseInt((width+height)*0.03125f), PApplet.parseInt((width+height)*0.03125f), 10);
  fill(0);
  textSize(PApplet.parseInt((width+height)*0.03125f));
  text((int)map(breakTime, 0, 1000, 1, 10), width*0.9f, height*0.9f); // Display af tid til pausen slutter
}

//-------------------------------------------------------------------------------------------------------------
class Player {

  Zombie zombie;

  PVector pos;
  PVector vel;
  PVector acc;

  boolean inMud;

  int size;
  int score;

  float limit;

  float mudLimit;
  float noLimit;


  Player() {
    zombie = new Zombie((int)random(width), (int)random(height));

    size = PApplet.parseInt((height+width)*0.01875f);
    score = 0;
    noLimit = PApplet.parseInt((height+width)*0.001875f);

    pos = new PVector(width*0.5f, height*0.5f);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }

  //------------------------------------------------------------------------------------------------------------- 

  public void update() {
    speedLimit();
    zombie.update();
    display();
    move();
    if (score<0) {
      score=0;
    }
  }

  //-------------------------------------------------------------------------------------------------------------

  public void display() {

    pushMatrix();
    translate(pos.x, pos.y);
    if (vel.mag()<=1) {
      rotate(zombie.vel.heading()-radians(90));
    } else {
      rotate(vel.heading()+radians(90));
    }
    image(playerImage, 0, 0, size, size);
    fill(200);
    popMatrix();
    textSize((height+width)*0.01f);
    int spd;
    if (inMud) {
      spd = 60;
    } else if(vel.mag()>1){
      spd = 100;
    } else {
      spd = 0;
    }
    text(spd, pos.x, pos.y - size);
  }

  //-------------------------------------------------------------------------------------------------------------

  public void move() {
    zombie.move(pos.x, pos.y);
    acc.add(mouseX-pos.x, mouseY-pos.y);
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    vel.limit(limit);
    if (dist(pos.x, pos.y, mouseX, mouseY)<5) {
      vel.mult(0);
    }
  }

  //-------------------------------------------------------------------------------------------------------------

  public boolean hit() { // retunere true, hvis man rør zombien
    return dist(pos.x, pos.y, zombie.pos.x, zombie.pos.y)<(zombie.size+size)*0.5f;
  }

  //-------------------------------------------------------------------------------------------------------------

  public void speedLimit() {
    noLimit = 3;
    mudLimit = noLimit*0.6f;
    if (inMud) {
      limit = mudLimit;
    } else {
      limit = noLimit;
    }
  }
}
class Point {

  PVector pos;
  
  int size;
  
  int valueOne;
  int valueTwo;
  int operator;
  int result;
  
  Point(int level_){
    size = PApplet.parseInt((width+height)*0.0125f);
    
    pos = new PVector((int)random(size,width-size),(int)random(size,height-size));
    
    
    operator = level_;
    
    valueOne = (int)random(1,11);
    valueTwo = (int)random(1,11); 
    
    if (operator==3){
      valueOne = valueTwo*(int)random(1,11);
    }
    
    calResult();
    
  }
  
  //-------------------------------------------------------------------------------------------------------------
  
  public void calResult(){
    if(operator==0){
      result = valueOne + valueTwo;
    } else if(operator==1){
      result = valueOne - valueTwo;
    } else if(operator==2){
      result = valueOne * valueTwo;
    } else if(operator==3){
      result = valueOne / valueTwo;
    }
    
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  public void update(){
    display();
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  public void display(){
    fill(200);
    textSize((width+height)*0.0125f);
    image(pointImage,pos.x,pos.y,size,size);
    text(operators[operator], pos.x, pos.y - size*0.2f);
  }


}
class Zombie {

  PVector pos;
  PVector vel;
  PVector acc;

  int size;

  float limit;

  float mudLimit;
  float noLimit;

  boolean inMud;
  
  PImage zombieImage;

  Zombie(int x, int y) {
    size = PApplet.parseInt((width+height)*0.025f);

    limit = (height+width)*0.000125f;

    zombieImage = loadImage("data/Zombie.png");

    pos = new PVector(x, y);
    vel = new PVector(limit, limit);
    acc = new PVector(0, 0);
  }

  //-------------------------------------------------------------------------------------------------------------

  public void update() {    
    speedLimit();
    noLimit += (height+width)*0.000000625f;
    display();
  }

  //------------------------------------------------------------------------------------------------------------- 

  public void display() {
    textSize((height+width)*0.01f);
    text(PApplet.parseInt(map(limit,0,3,0,100)), pos.x, pos.y - size);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(vel.heading()+radians(90));
    image(zombieImage,0,0,size,size);
    popMatrix();
  }

  //------------------------------------------------------------------------------------------------------------- 

  public void move(float x, float y) {
    if (limit<0) {
      limit = 0;
    }
    acc.add(x-pos.x, y-pos.y);
    pos.add(vel);
    vel.add(acc);
    vel.limit(limit);
    acc.mult(0);
    if (dist(pos.x, pos.y, mouseX, mouseY)<2) {
      vel.mult(0);
    }
  }

  //------------------------------------------------------------------------------------------------------------- 

  public void speedLimit() {
    mudLimit = noLimit*0.6f; 
    if (inMud) {
      limit = mudLimit;
    } else {
      limit = noLimit;
    }
  }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Spil" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
