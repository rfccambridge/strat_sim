
class SoccerBall extends Ball {
  
  public SoccerBall() {
    super(width/2,height/2,10,10, color(150));
  }
  
  public SoccerBall(Ball b) {
    super(0,0,1,1,color(0));
    this.position = b.position.get();
    this.velocity = b.velocity.get();
  }

}
