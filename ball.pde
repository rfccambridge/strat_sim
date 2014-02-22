
/*
  handles bouncing for robots and soccerball
*/

abstract class Ball {
  
  PVector position;
  PVector velocity;
  
  // how bouncy the ball is
  float bnc = -.5;
  float spring = .4;
  float damp = -.3;
  float r, m;
  color c;

  Ball(float x, float y, float r_, float m_, color c_) {
    position = new PVector(x, y);
    velocity = new PVector(3,3);
    r = r_;
    m = m_;
    c = c_;
  }

  public void update() {
    position.add(velocity);
    //velocity.mult(.9);
    noStroke();
    fill(c);
    ellipse(position.x,position.y,2*r,2*r);
  }

  public void checkBoundaryCollision() {
    if (position.x > width-r) {
      position.x = width-r;
      velocity.x *= bnc;
    } 
    else if (position.x < r) {
      position.x = r;
      velocity.x *= bnc;
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

  public void checkCollision(Ball other) {

    // get distances between the balls components
    PVector dx = PVector.sub(other.position, position);
    PVector dv = PVector.sub(other.velocity, velocity);
    
    float mindist = r + other.r;
    if (dx.mag() < mindist) {
      // calculate spring component
      PVector indent = dx.get();
      indent.setMag(mindist);
      indent.sub(dx);
      PVector Fs = PVector.mult(indent,spring);
      
      // calculate damping
      PVector dx_hat = dx.get();
      dx_hat.normalize();
      float dot = dv.dot(dx_hat) * damp;
      PVector Fd = dx_hat.get();
      Fd.mult(dot);
      PVector accel = PVector.add(Fs,Fd);
      velocity.sub(accel);
      other.velocity.add(accel);
      
    }
  }
}
