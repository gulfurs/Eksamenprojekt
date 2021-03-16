Player player;

ArrayList<Point> point;

void setup() {
  size(400,400);
  player = new Player();
  point = new ArrayList<Point>();
  point.add(new Point());
}

  //------------------------------------------------------------------------------------------------------------- 

void draw() {
  background(200);
  player.update();
  hit();
  
  player.zombie.limit += 0.001;
  
  for(int i = 0; i < point.size(); i++ ){
    point.get(i).update();
  }
  
  if(player.hit()){
    frameCount = -1;
  }
  
  println(player.zombie.limit);
  
}

  //------------------------------------------------------------------------------------------------------------- 

void mousePressed() {
  point.add(new Point());
}

  //------------------------------------------------------------------------------------------------------------- 

void hit(){
  for(int i = 0; i < point.size(); i++ ){
    float d = dist(player.pos.x,player.pos.y, point.get(i).pos.x,point.get(i).pos.y);
    if(d<(point.get(i).size+player.size)*0.5){
      point.remove(i);
      if(player.zombie.limit>0){
        player.zombie.limit -= 0.1;
      }
    }
  }
}
