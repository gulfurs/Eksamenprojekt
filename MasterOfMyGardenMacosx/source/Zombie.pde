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
    size = int((width+height)*0.025);

    limit = (height+width)*0.000125;

    zombieImage = loadImage("data/Zombie.png");

    pos = new PVector(x, y);
    vel = new PVector(limit, limit);
    acc = new PVector(0, 0);
  }

  //-------------------------------------------------------------------------------------------------------------

  void update() {    
    speedLimit();
    noLimit += (height+width)*0.000000625;
    display();
  }

  //------------------------------------------------------------------------------------------------------------- 

  void display() {
    textSize((height+width)*0.01);
    text(int(map(limit,0,3,0,100)), pos.x, pos.y - size);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(vel.heading()+radians(90));
    image(zombieImage,0,0,size,size);
    popMatrix();
  }

  //------------------------------------------------------------------------------------------------------------- 

  void move(float x, float y) {
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

  void speedLimit() {
    mudLimit = noLimit*0.6; 
    if (inMud) {
      limit = mudLimit;
    } else {
      limit = noLimit;
    }
  }
}
