class Zombie{

  PVector pos;
  PVector vel;
  PVector acc;
  
  int size;
  
  Zombie(){
    size = 10;
   
    pos = new PVector(width*0.5,height*0.5);
    vel = new PVector(0,0);
    acc = new PVector(0,0);
  
  }
  
  
  void display(){
    shapeMode(CENTER);
    triangle(pos.x,pos.y - size,pos.x-(size/2),pos.y,pos.x+(size/2),pos.y);
  }
  
}
