Player player; // Spilleren

Point currentPoint; // Pointet/regnestykket man er i gang med at løse

ArrayList<Point> point; // Liste over de point/regnestykker der er på banen

PImage lakeImage;
PImage background;

int count; // Bliver brugt til at spawne regnestykker
int guess; // Det tal man gætter på når man skal regne et regnestykke
int result; // Resultatet af regnestykket
int level; // Det level man er på(+, -, * eller /)
int breakTime; // Pausetiden (ca. 10 sek)
int lakeSize; // Størrelsen af søen


boolean pause; // Bestemmer om der er pause fra spillet
boolean dead; // Bestemmer om man er død
boolean inGame; // Bestemmer om man er i gang med spillet

char[] operators; // +, -, * eller /

PVector lake;
PVector axisX;

void setup() {
  size(400, 400); // Størrelsen af vinduet

  textAlign(CENTER, CENTER); // (CENTER,CENTER) eller bare (CENTER) // Ligesom rectMode(CENTER) bare med tekst
  textSize(20); // Størrelse af teksten
  imageMode(CENTER);

  lakeImage = loadImage("data/Lake.png");
  background = loadImage("data/Background.png");

  player = new Player(); // Initialisering af spilleren
  level = 0; // Nulstil level
  guess = 0; // Nulstil guess
  count = 0; // Nulstil count

  lake = new PVector(player.zombie.pos.x, player.zombie.pos.y);
  axisX = new PVector(1, 0);

  point = new ArrayList<Point>(); // Initialisering af point listen
  point.add(new Point(level)); // Tilføjelse af point/regnestykke til listen

  breakTime = 1000; // Initialisering af breakTime til 1000 
  lakeSize = int(random((width*0.1+height*0.1), (width*0.4+height*0.4)));

  pause = false; 
  inGame = true;
  dead = false;

  operators = new char[4]; // Initialisering af de fire forskellige operators
  operators[0] = '+';
  operators[1] = '-';
  operators[2] = '*';
  operators[3] = '/';

  mouseX = (int)player.pos.x; // Så bevæger man sig ikke efter man lige har svaret
  mouseY = (int)player.pos.y; // Så bevæger man sig ikke efter man lige har svaret
}

//------------------------------------------------------------------------------------------------------------- 

void draw() {

  if (dead) {           // Hvis spilleren er død

    endScreen();        // Viser slut skærmen
  } else {              // Hvis spilleren er i live

    if (pause) {        // Pauser spillet og viser regnestykket // Hvis spillet er på pause

      if (inGame) {     // Hvis man er inden i spillet
        calculationScreen();
      } else { // pause skærm
        image(background, width*0.5, height*0.5, width, height); // Sætter baggrund
        slowZone(); // viser søen
        player.display(); // Viser spilleren
        player.zombie.display(); // Viser zombien
        updatePoints();  // Updaterer pointene
        textSize(100);
        text("Pause", width*0.5, height*0.2); // Viser spillerens score
        textSize(40);
        text(player.score, width*0.5, height*0.5); // Viser spillerens score
        text("Du er på level: " + int(level+1), width*0.5, height*0.7); // Viser spillerens score
      }

      breakTime--;     // Nedsætting af pausetid

      noStroke();
      fill(255);
      rectMode(CORNER);
      rect(width*0.836, height*0.85, 50, 50, 10);
      fill(0);
      textSize(50);
      text((int)map(breakTime, 0, 1000, 0, 10), width*0.9, height*0.9); // Display af tid til pausen slutter
      textSize(20);

      if (breakTime<0) {
        pause = false;
        inGame = true;
        breakTime = 1000;
        guess = 0;
        player.score--;
      }
    } else {           // Her er koden til selve spillet
      image(background, width*0.5, height*0.5, width, height); // Sætter baggrund
      slowZone();
      fill(200);
      textSize(100);
      text(player.score, width*0.5, height*0.8,100); // Viser spillerens score
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
}

//------------------------------------------------------------------------------------------------------------- 

void mousePressed() {
  if (dead) {
    dead = false;
    frameCount = -1;
  }

  if (inGame) { // Hvis man er inde i spillet
    if (pause && (mouseX>width*1/3 && mouseX<width*2/3 && mouseY>height*4/6 && mouseY<height*5/6)) { // Hvis det klikkes på den blå firkant
      if (guess == result) { // Hvis man har svaret rigtigt
        player.score++; // Score forøges
        if (player.zombie.limit>0) {
          player.zombie.limit -= 0.30; // zombien bliver langsommere
        }
      } else if (guess != result) { // Hvis man har svaret forkert
        player.score--; // Score formindskes
        player.zombie.limit += 0.1; // zombien bliver hurtigere
      }
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
  mouseX = (int)player.pos.x; // Så bevæger man sig ikke efter man lige har svaret
  mouseY = (int)player.pos.y; // Så bevæger man sig ikke efter man lige har svaret
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
  textSize(70);
  text("Game Over!", width*0.5, height*0.5); // Skriver "Game Over!" midt på skærmen
}

//-------------------------------------------------------------------------------------------------------------

void spawnPoint() {
  if (count > 300) { // Count større end 300
    point.add(new Point(level)); // Tilføjelse af nyt point/regnestykke til listen
    count = 0; // count nulstilles
  } else {
    count++; // count forøges med 1
  }
}

//-------------------------------------------------------------------------------------------------------------

void keyPressed() {
  mouseX = (int)player.pos.x; // Så bevæger man sig ikke efter man lige har svaret
  mouseY = (int)player.pos.y; // Så bevæger man sig ikke efter man lige har svaret

  if (key == 'p' || key == 'P') { // Der trykkes på p og Spillet pauses
    if (pause && !inGame) { // Hvis man allerede er på pause
      breakTime = 10;
    } else if (!pause && inGame) {
      pause = true;
      inGame = false;
    }
  } 

  if (dead && key == ENTER) {
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
      if (guess == result) {
        player.score++;
        player.zombie.noLimit *= 0.70;
      } else if (guess != result) {
        player.score--;
        player.zombie.noLimit *= 1.1;
      }
      mouseX = (int)player.pos.x; // Så bevæger man sig ikke efter man lige har svaret
      mouseY = (int)player.pos.y; // Så bevæger man sig ikke efter man lige har svaret
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
  text(currentPoint.valueOne + " " + operators[currentPoint.operator] + " " + currentPoint.valueTwo, width*0.5, height*0.27);
  text("Gæt: " + guess, width*0.5, height*0.5);
  text("+", width*0.75, height*0.5);
  text("-", width*0.25, height*0.5);
  text("Enter", width*0.5, height*0.76);
}

//-------------------------------------------------------------------------------------------------------------

void slowZone() {
  float distPlayer = dist(lake.x, lake.y, player.pos.x, player.pos.y);
  float distZombie = dist(lake.x, lake.y, player.zombie.pos.x, player.zombie.pos.y);
  noFill();
  image(lakeImage, lake.x, lake.y, lakeSize, lakeSize);
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
