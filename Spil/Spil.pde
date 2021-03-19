Player player;

ArrayList<Point> point;

int count;

void setup() {
  size(400,400);
  player = new Player();
  point = new ArrayList<Point>();
  point.add(new Point());
  count = 0;
  
}

  //------------------------------------------------------------------------------------------------------------- 

void draw() {
  background(200);
  player.update();
  updatePoints();
  hit(); // Tjekker om spilleren rør et point    
  endScreen();
  spawnPoint();
   
    /*
  if(//rammer et point){
    // regestykke kommer frem
  } else if (// spillet er slut){
    // slut skærm
  } else {
    // normale spil funktioner
  }
  */
    
}

  //------------------------------------------------------------------------------------------------------------- 

void mousePressed() {
}

  //------------------------------------------------------------------------------------------------------------- 

void hit(){
  for(int i = 0; i < point.size(); i++ ){
    float d = dist(player.pos.x,player.pos.y, point.get(i).pos.x,point.get(i).pos.y);
    if(d<(point.get(i).size+player.size)*0.5){
      point.remove(i);
      if(player.zombie.limit>0){
        player.zombie.limit -= 0.2;
      }
    }
  }
}

  //------------------------------------------------------------------------------------------------------------- 

void updatePoints(){
  for(int i = 0; i < point.size(); i++ ){
    point.get(i).update();
  }
}

  //------------------------------------------------------------------------------------------------------------- 

void endScreen(){
  if(player.hit()){
    frameCount = -1;
  }
}

//-------------------------------------------------------------------------------------------------------------

void spawnPoint(){
  if(count > 300){
    point.add(new Point());
    count = 0;
  } else {
    count++;
  }
}
