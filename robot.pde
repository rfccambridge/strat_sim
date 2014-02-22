

class Robot extends Ball {
  
  float max_mag = 5;
  float max_accel = 2;
  float drag = .8;
  
  public Robot() {
    super(random(width),random(height),15,15,color(100,100,100));
  }
  
  public void instruct(PVector target, Boolean kick) {
    // go to target
    PVector accel = PVector.sub(target,position);
    accel.setMag(accel.mag()*accel.mag()/100);
    accel.limit(max_accel);
    velocity.add(accel);
    velocity.mult(drag);
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
  Boolean[] kicks;
  
  public CmdSet(int n_) {
    n = n_;
    targets = new PVector[n];
    kicks = new Boolean[n];
    
    for (int i=0; i<n; i++) {
      targets[i] = new PVector();
      kicks[i] = false;
    }
  }
}
    
    
    
  
