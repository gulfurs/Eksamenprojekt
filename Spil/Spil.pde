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
  
  for(int i = 0; i < point.size(); i++ ){
    point.get(i).update();
  }
  
  if(player.hit()){
    frameCount = -1;
  }
  
}

  //------------------------------------------------------------------------------------------------------------- 

void mousePressed() {
  
}
