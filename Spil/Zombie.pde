class Zombie{

  PVector pos;
  PVector vel;
  PVector acc;
  
  int size;
  
  float limit;
  
  Zombie(int x, int y){
    size = 20;
   
    limit = 0.2;
   
    pos = new PVector(x,y);
    vel = new PVector(limit,limit);
    acc = new PVector(0,0);
  
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void display(){
    shapeMode(CENTER);
    triangle(pos.x,pos.y - size,pos.x-(size/2),pos.y,pos.x+(size/2),pos.y);
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void move(float x, float y){
    acc.add(x-pos.x,y-pos.y);
    pos.add(vel);
    vel.add(acc);
    vel.limit(limit);
    acc.mult(0);
    if(dist(pos.x,pos.y,mouseX,mouseY)<2){
      vel.mult(0);
    }
  }
  
}
