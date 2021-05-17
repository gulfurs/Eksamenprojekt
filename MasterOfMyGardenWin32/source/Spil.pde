import processing.sound.*;
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

void setup() {
  size(800, 800); // Størrelsen af vinduet

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
  ding.amp(0.8);
  buzz.amp(0.8);

  player = new Player(); // Initialisering af spilleren
  level = 0; // Nulstil level
  guess = 0; // Nulstil guess
  count = 0; // Nulstil count
  wrongAnswerRate = 1.0;

  lake = new PVector(player.zombie.pos.x, player.zombie.pos.y);
  axisX = new PVector(1, 0);

  point = new ArrayList<Point>(); // Initialisering af point listen
  point.add(new Point(level)); // Tilføjelse af point/regnestykke til listen

  breakTime = 1000; // Initialisering af breakTime til 1000 

  lakeSize = (int)random((width+height)*0.125, (width+height)*0.35);
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

void draw() {
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
        image(background, width*0.5, height*0.5); // Sætter baggrund
        slowZone();
        fill(200);
        textSize(int((width+height)*0.0625));
        text(player.score, width*0.5, height*0.8, 100); // Viser spillerens score
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

void mousePressed() {  
  if (startScreen && mouseX > int((width+height)*0.140625) && mouseX < int((width+height)*0.365625) && mouseY > int((width+height)*0.34375) && mouseY < int((width+height)*0.375)) {
    exit();
  } else if(startScreen && mouseX > int((width+height)*0.15625) && mouseX < int((width+height)*0.353125) && mouseY > int((width+height)*0.15625) && mouseY < int((width+height)*0.1875)){
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

    if (pause && mouseX > width*0.5) { // Hvis pause of klik til højre
      guess++; // guess forøges med 1
    }

    if (pause && mouseX < width*0.5) { // Hvis pause og klik til venstre
      guess--; // guess formindskes med 1
    }
  }
  doNotMove();
}

//------------------------------------------------------------------------------------------------------------- 

void hit() { 
  for (int i = 0; i < point.size(); i++ ) { // Looper gennem alle point/regnestykker
    float d = dist(player.pos.x, player.pos.y, point.get(i).pos.x, point.get(i).pos.y); // Afstanden mellem point og spilleren
    if (d<(point.get(i).size+player.size)*0.5) { // Hvis afstanden er mindre end deres radius
      pause = true; // Spillet pauses
      breakTime = 1000; // breakTime sættes
      currentPoint = point.get(i); // currentPoint sættes til det point man har ramt
      result = point.get(i).result; // resultatet beregnes for det point/regnestykke man har ramt
      point.remove(i); // pointet/regnestykket fjernes fra banen(så man ikke kan ramme det flere gange)
    }
  }
}

//------------------------------------------------------------------------------------------------------------- 

void updatePoints() {
  for (int i = 0; i < point.size(); i++ ) { // Looper gennem alle point/regnestykker
    point.get(i).update(); // alle point/regnestykker opdateres
  }
}

//------------------------------------------------------------------------------------------------------------- 

void endScreen() {
  textSize(int((width+height)*0.04375));
  text("Game Over", width*0.5, height*0.5); // Skriver "Game Over!" midt på skærmen
  textSize(int((width+height)*0.0125));
  text("Tryk 'r', ENTER eller på skærmen for at genstarte spillet", width*0.5, height*0.6);
}

//-------------------------------------------------------------------------------------------------------------

void spawnPoint() {
  if (count > 200) { // Count større end 300
    point.add(new Point(level)); // Tilføjelse af nyt point/regnestykke til listen
    count = 0; // count nulstilles
  } else {
    count++; // count forøges med 1
  }
}

//-------------------------------------------------------------------------------------------------------------

void keyPressed() {
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

void level() {
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

void calculationScreen() {
  ding.stop();
  buzz.stop();

  rectMode(CORNER);
  noStroke();

  //Rød firkant
  fill(255, 0, 0, 150);
  rect(0, 0, width*0.5, height);

  //Grøn firkant
  fill(0, 255, 0, 150);
  rect(width*0.5, 0, width*0.5, height);

  //Blå firkant
  fill(0, 0, 255, 150);
  rect(width*1/3, height*4/6, width*1/3, height*1/6);

  //Hvid firkant
  fill(255);
  rect(width*1/3, height*1/6, width*1/3, height*1/6);

  fill(0); //Tilbage til sort
  stroke(0);
  textSize((width+height)*0.025);
  text(currentPoint.valueOne + " " + operators[currentPoint.operator] + " " + currentPoint.valueTwo, width*0.5, height*3/12);
  text("Gæt: " + guess, width*0.5, height*0.5);
  text("+", width*0.75, height*0.5);
  text("-", width*0.25, height*0.5);
  text("Enter", width*0.5, height*9/12);
  textSize((width+height)*0.008);
  text("(→)", width*0.75, height*0.55);
  text("(←)", width*0.25, height*0.55);
}

//-------------------------------------------------------------------------------------------------------------

void slowZone() {
  float distPlayer = dist(lake.x, lake.y, player.pos.x, player.pos.y);
  float distZombie = dist(lake.x, lake.y, player.zombie.pos.x, player.zombie.pos.y);
  image(lakeImage, lake.x, lake.y);
  if (distPlayer < lakeSize*0.5 + player.size*0.5) {
    player.inMud = true;
  } else {
    player.inMud = false;
  } 

  if (distZombie < lakeSize*0.5 + player.zombie.size*0.5) {
    player.zombie.inMud = true;
  } else {
    player.zombie.inMud = false;
  }
}

//-------------------------------------------------------------------------------------------------------------

void startScreen() {
  if (startScreen && mouseX > int((width+height)*0.140625) && mouseX < int((width+height)*0.365625) && mouseY > int((width+height)*0.34375) && mouseY < int((width+height)*0.375)) { 
    background(startImage[1]);
  } else if(startScreen && mouseX > int((width+height)*0.15625) && mouseX < int((width+height)*0.353125) && mouseY > int((width+height)*0.15625) && mouseY < int((width+height)*0.1875)){
    background(startImage[2]);
  } else {
    background(startImage[0]);
  }
}

//-------------------------------------------------------------------------------------------------------------

void pauseScreen() {
  image(background, width*0.5, height*0.5); // Sætter baggrund
  slowZone(); // viser søen
  player.display(); // Viser spilleren
  player.zombie.display(); // Viser zombien
  updatePoints();  // Updaterer pointene
  textSize(int((width+height)*0.0625));
  text("Pause", width*0.5, height*0.2); // Viser spillerens score
  textSize(int((width+height)*0.01875));
  text("Din score er: " + player.score, width*0.5, height*0.5); // Viser spillerens score
  text("Du er på level: " + int(level+1), width*0.5, height*0.7); // Viser spillerens level
  textSize(int((width+height)*0.0125));
  text("Tryk 'p' for at afslutte pausen", width*0.5, height*0.3);
  text("Tryk 'r' for at genstarte spillet", width*0.5, height*0.8);
}

//-------------------------------------------------------------------------------------------------------------

void checkGuessAndResult() {
  if (guess == result) {
    ding.play();
    player.score++;
    player.zombie.noLimit *= 0.70;
  } else if (guess != result) {
    buzz.play();
    wrongAnswerRate += 0.05;
    player.score--;
    player.zombie.noLimit *= wrongAnswerRate;
  }
}

//-------------------------------------------------------------------------------------------------------------

void doNotMove() {
  mouseX = (int)player.pos.x; // Så bevæger man sig ikke 
  mouseY = (int)player.pos.y; // Så bevæger man sig ikke 
}

//-------------------------------------------------------------------------------------------------------------

void countDown() {
  noStroke();
  fill(255);
  rectMode(CENTER);
  rect(width*0.9, height*0.905, int((width+height)*0.03125), int((width+height)*0.03125), 10);
  fill(0);
  textSize(int((width+height)*0.03125));
  text((int)map(breakTime, 0, 1000, 1, 10), width*0.9, height*0.9); // Display af tid til pausen slutter
}

//-------------------------------------------------------------------------------------------------------------
