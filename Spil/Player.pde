class Player{

  Zombie zombie;
  
  PVector pos;
  PVector vel;
  PVector acc;
  
  int size;
  
  Player(){
    zombie = new Zombie(0,0);
    
    size = 10;
   
    pos = new PVector(width*0.5,height*0.5);
    vel = new PVector(0,0);
    acc = new PVector(0,0);
    
  }
  
  //------------------------------------------------------------------------------------------------------------- 
  
  void update(){
    zombie.limit += 0.001;
    display();
    move();
  }
  
  //-------------------------------------------------------------------------------------------------------------
  
  void display(){
    ellipseMode(CENTER);
    zombie.display();
    ellipse(pos.x,pos.y,size,size);
  }
  
  //-------------------------------------------------------------------------------------------------------------

  void move(){
    zombie.move(pos.x,pos.y);
    acc.add(mouseX-pos.x,mouseY-pos.y);
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    vel.limit(2);
    if(dist(pos.x,pos.y,mouseX,mouseY)<2){
      vel.mult(0);
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------
  
  boolean hit(){
    return dist(pos.x,pos.y,zombie.pos.x,zombie.pos.y)<(zombie.size+size)*0.5;
  }
  
}
