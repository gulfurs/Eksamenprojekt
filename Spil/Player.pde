class Player{

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
  
  PImage playerImage;
  
  Player(){
   zombie = new Zombie((int)random(width),(int)random(height));
   
   playerImage = loadImage("data/Player.png");
   
   size = 20;
   score = 0;
   noLimit = 3;
   
   pos = new PVector(width*0.5,height*0.5);
   vel = new PVector(0,0);
   acc = new PVector(0,0);
    
  }
  
  //------------------------------------------------------------------------------------------------------------- 
  
  void update(){
    speedLimit();
    zombie.update();
    display();
    move();
    if(score<0){score=0;}
  }
  
  //-------------------------------------------------------------------------------------------------------------
  
  void display(){
    //ellipseMode(CENTER);
    //ellipse(pos.x,pos.y,size,size);
    pushMatrix();
    translate(pos.x, pos.y);
    if(vel.mag()<=1){
      rotate(zombie.vel.heading()-radians(90));
    } else {
      rotate(vel.heading()+radians(90));
    }
    image(playerImage,0,0,size,size);
    popMatrix();
    textSize(12);
    text(int(map(vel.mag(),0,3,0,100)), pos.x, pos.y - size*2);
  }
  
  //-------------------------------------------------------------------------------------------------------------

  void move(){
    zombie.move(pos.x,pos.y);
    acc.add(mouseX-pos.x,mouseY-pos.y);
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    vel.limit(limit);
    if(dist(pos.x,pos.y,mouseX,mouseY)<5){
      vel.mult(0);
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------
  
  boolean hit(){ // retunere true, hvis man rør zombien
    return dist(pos.x,pos.y,zombie.pos.x,zombie.pos.y)<(zombie.size+size)*0.5;
  }

  //-------------------------------------------------------------------------------------------------------------

  void speedLimit(){
    noLimit = 3;
    mudLimit = noLimit*0.6;
    if(inMud){
      limit = mudLimit;
    } else {
      limit = noLimit;
    }
  } 
  
}
