class Point{

  PVector pos;
  //PVector vel;
  //PVector acc;
  
  int size;
  
  int valueOne;
  int valueTwo;
  int operator;
  int result;
  
  PImage pointImage;
  
  Point(int level_){
    size = 20;
    
    pos = new PVector((int)random(size,width-size),(int)random(size,height-size));
    
    pointImage = loadImage("data/Point.png");
    
    operator = level_;
    
    valueOne = (int)random(1,11);
    valueTwo = (int)random(1,11); 
    
    if (operator==3){
      valueOne = valueTwo*(int)random(1,11);
    }
    
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
      result = valueOne / valueTwo; //Fejl med at dividere med 0
    }
    
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void update(){
    display();
  }
  
  //------------------------------------------------------------------------------------------------------------- 

  void display(){
    textSize(20);
    image(pointImage,pos.x,pos.y,size,size);
    text(operators[operator], pos.x, pos.y - size*0.2);
  }


}
