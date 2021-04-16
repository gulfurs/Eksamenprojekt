Player player; // Spilleren

Point currentPoint; // Pointet/regnestykket man er i gang med at løse

ArrayList<Point> point; // Liste over de point/regnestykker der er på banen

int count; // Bliver brugt til at spawne regnestykker
int guess; // Det tal man gætter på når man skal regne et regnestykke
int result; // Resultatet af regnestykket
int level; // Det level man er på(+, -, * eller /)
int breakTime; // Pausetiden (ca. 10 sek)

boolean pause; // Bestemmer om der er pause fra spillet
boolean dead; // Bestemmer om man er død
boolean inGame; // Bestemmer om man er i gang med spillet

char[] operators; // +, -, * eller /

void setup() {
  size(400, 400); // Størrelsen af vinduet

  textAlign(CENTER,CENTER); // (CENTER,CENTER) eller bare (CENTER) // Ligesom rectMode(CENTER) bare med tekst
  textSize(20); // Størrelse af teksten

  player = new Player(); // Initialisering af spilleren
  level = 0; // Nulstil level
  guess = 0; // Nulstil guess
  count = 0; // Nulstil count


  point = new ArrayList<Point>(); // Initialisering af point listen
  point.add(new Point(level)); // Tilføjelse af point/regnestykke til listen

  currentPoint = point.get(0); // Sætter currentPoint til at være det første point/regnestykke
  result = currentPoint.result; // Initialisering af result
  point.remove(0); // Fjerner point/regnestykke fra listen

  breakTime = 1000; // Initialisering af breakTime til 1000 
  
  pause = true; // 
  inGame = true;
  dead = false;

  operators = new char[4]; // Initialisering af de fire forskellige operators
  operators[0] = '+';
  operators[1] = '-';
  operators[2] = '*';
  operators[3] = '/';
}

//------------------------------------------------------------------------------------------------------------- 

void draw() {
  background(200); // Sætter baggrund
  
  
  
  if (dead) {           // Hvis spilleren er død
  
    endScreen();        // Viser slut skærmen
    
  } else {              // Hvis spilleren er i live
  
    if (pause) {        // Pauser spillet og viser regnestykket // Hvis spillet er på pause
    
      if (inGame) {     // Hvis man er inden i spillet
      
        calculationScreen();
        
      } else {
                       //pause skærm
      }

      breakTime--;     // Nedsætting af pausetid

      text((int)map(breakTime,0,1000,0,10),width*0.2,height*0.2); // Display af tid til pausen slutter

      if (breakTime<0) {
        pause = false;
        inGame = true;
        breakTime = 1000;
      }
      
      
    } else {           // Her er koden til selve spillet
      background(200);
      text(player.score, width*0.5, height*0.5); // Viser spillerens score
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

  if (pause && (mouseX>width*1/3 && mouseX<width*2/3 && mouseY>height*4/6 && mouseY<height*5/6)) {
    if (guess == result) {
      guess = 0;
      player.score++;
      pause = false;
      if (player.zombie.limit>0) {
        player.zombie.limit -= 0.30;
      }
    } else if (guess != result) {
      guess = 0;
      player.score--;
      pause = false;
      player.zombie.limit += 0.1;
    }
  }

  if (pause && mouseX > width*0.5) {
    guess++;
  }

  if (pause && mouseX < width*0.5) {
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
  text("Game Over!", width*0.5, height*0.5);
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
  
  if(key == 'p' || key == 'P'){
    println("p");
    pause = true;
    inGame = false;
  } 
  
  if (dead && key == ENTER) {
    dead = false;
    frameCount = -1;
  }

  if (pause && keyCode == RIGHT) {
    guess++;
  }

  if (pause && keyCode == LEFT) {
    guess--;
  }

  if (key == ENTER && pause) {
    if (guess == result) {
      guess = 0;
      player.score++;
      pause = false;
      if (player.zombie.limit>0) {
        player.zombie.limit -= 0.30;
      }
    } else if (guess != result) {
      guess = 0;
      player.score--;
      pause = false;
      player.zombie.limit += 0.1;
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
  strokeWeight(5);
  text(currentPoint.valueOne + " " + operators[currentPoint.operator] + " " + currentPoint.valueTwo, width*0.5, height*0.27);
  text("Gæt: " + guess, width*0.5, height*0.5);
  text("+", width*0.75, height*0.5);
  text("-", width*0.25, height*0.5);
  text("Enter", width*0.5, height*0.76);
}

//-------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------
