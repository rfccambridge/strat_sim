class SoccerBall extends Ball {
  
  float friction = .14;
  
  public SoccerBall() {
    super(width/2,height/2,4,4, color(150));
  }
  
  public SoccerBall(Ball b) {
    super(0,0,1,1,color(0));
    this.position = b.position.get();
    this.velocity = b.velocity.get();
  }
  
  public void update() {
    if (this.velocity.mag() < friction) {
      this.velocity.mult(0);
    }
    else {
      this.velocity.setMag(this.velocity.mag() - friction);
    }
    super.update();
  }
  
  public void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= bnc;
      
      if (abs(position.y - height/2) < goal_width/2) {
        // goal
        scoreR++;
        reset();
      }
    } 
    else if (position.x < r) {
      position.x = r;
      velocity.x *= bnc;
      if (abs(position.y - height/2) < goal_width/2) {
        // goal
        scoreB++;
        reset();
      }
    } 
    if (position.y > height-r) {
      position.y = height-r;
      velocity.y *= bnc;
    } 
    else if (position.y < r) {
      position.y = r;
      velocity.y *= bnc;
    }
  }
}


