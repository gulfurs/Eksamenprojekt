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

    size = int((height+width)*0.01875);
    score = 0;
    noLimit = int((height+width)*0.001875);

    pos = new PVector(width*0.5, height*0.5);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
  }

  //------------------------------------------------------------------------------------------------------------- 

  void update() {
    speedLimit();
    zombie.update();
    display();
    move();
    if (score<0) {
      score=0;
    }
  }

  //-------------------------------------------------------------------------------------------------------------

  void display() {

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
    textSize((height+width)*0.01);
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

  void move() {
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

  boolean hit() { // retunere true, hvis man rør zombien
    return dist(pos.x, pos.y, zombie.pos.x, zombie.pos.y)<(zombie.size+size)*0.5;
  }

  //-------------------------------------------------------------------------------------------------------------

  void speedLimit() {
    noLimit = 3;
    mudLimit = noLimit*0.6;
    if (inMud) {
      limit = mudLimit;
    } else {
      limit = noLimit;
    }
  }
}
