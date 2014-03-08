

class Robot extends Ball {
  
  // movement
  float max_accel = 3;

  float drag = .7;;  
  // kicking

  float kick_speed = 20;
  float noise_scale = 2; 
  float kick_range = 10;
  
  
  
  public Robot() {
    super(random(width),random(height),10,13,color(100,100,100));
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

      float dist = PVector.sub(ball.position,position).mag();
      
      
      
      if (dist < kick_range + r + ball.r) {
        // in kicking range
        kick.setMag(kick_speed);
        PVector noise = PVector.random2D();
        noise.mult(noise_scale);
        kick.add(noise);
        ball.velocity = kick.get();
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
    
    
    
  
