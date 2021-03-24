class Point{

  PVector pos;
  //PVector vel;
  //PVector acc;
  
  int size;
  
  int valueOne;
  int valueTwo;
  int operator;
  int result;
  
  Point(){
    size = 10;
    
    pos = new PVector((int)random(size,width-size),(int)random(size,height-size));
    
    valueOne = (int)random(5);
    valueTwo = (int)random(5);
    
    operator = 0;
    
    calResult();
    
  }
  
  //-------------------------------------------------------------------------------------------------------------
  
  void calResult(){
    if(operator==0){
      result = valueOne + valueTwo;
    } else if(operator==1){
      result = valueOne - valueTwo;
    } else if(operator==2){
      result = valueOne * valueTwo;
    } else if(operator==3){
      result = valueOne / valueTwo;
    }
    
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void update(){
    display();
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void display(){
    textAlign(CENTER);
    text(valueOne + " " + operators[operator] + " " + valueTwo, pos.x, pos.y - size);
    rectMode(CENTER);
    rect(pos.x,pos.y,size,size);
  }


}
