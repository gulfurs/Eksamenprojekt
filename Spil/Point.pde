class Point{

  PVector pos;
  //PVector vel;
  //PVector acc;
  
  int size;
  
  Point(){
    size = 10;
    
    pos = new PVector((int)random(size,width-size),(int)random(size,height-size)); 
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void update(){
    display();
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void display(){
    rect(pos.x,pos.y,size,size);
  }


}
