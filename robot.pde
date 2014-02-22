

class Robot extends Ball {
  
  // movement
  float max_accel = 3;

  float drag = .7;;  
  // kicking

  float kick_speed = 20;
  
  public Robot() {
    super(random(width),random(height),13,13,color(100,100,100));
  }
  public Robot(Boolean side) {
    //true means start on right
    this();
    this.position.x = random(width/2);
    this.position.y = random(height);
    
    this.c = color(200,51,51);
    
    if (side) {
      this.position.x += width/2;
      this.c = color(51,51,200);
    }
  }
  
  public void instruct(PVector target, PVector kick, SoccerBall ball) {
    // go to target
    PVector accel = PVector.sub(target,position);
    accel.setMag(accel.mag()*accel.mag()/100);
    accel.limit(max_accel);
    velocity.add(accel);

    velocity.mult(drag);    
    // kicking
    if (kick != null && kick.mag() != 0) {
      

  
      kick.normalize();
      PVector diff = PVector.sub(ball.position,position);
      float dx = abs(diff.cross(kick).mag());
      float dy = abs(diff.dot(kick));
      
      float max_x = r/2 + ball.r/2;
      float max_y = r + ball.r + 10;
      
      if (dx < max_x && dy < max_y) {
        // in kicking range
        kick.setMag(kick_speed);
        ball.velocity.add(kick);
      }
    } 
  }
}

// group of robot information for passing to behavior
class Team {
  int n;
  PVector[] positions;
  PVector[] velocities;
  
  public Team(int n_) {
    n = n_;
    positions = new PVector[n];
    velocities = new PVector[n];
    
    for (int i=0; i < n; i++) {
      positions[i] = new PVector();
      velocities[i] = new PVector();
    }
  }
}

// for passing instructions back from behavior
class CmdSet {
  int n;
  PVector[] targets;
  PVector[] kicks;
  
  public CmdSet(int n_) {
    n = n_;
    targets = new PVector[n];
    kicks = new PVector[n];
    
    for (int i=0; i<n; i++) {
      targets[i] = new PVector();
      kicks[i] = null;
    }
  }
}
    
    
    
  
