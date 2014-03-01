class shreyabehaviour extends Behavior {

  // true means goal is on right
  public shreyabehaviour(Boolean side) {
    super(side);
  }
  
  public void reset(String msg) {
  }

  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    
    for (int i=0; i<n; i++) {
      cmds.targets[i] = new PVector(mouseX,mouseY);
      if (mousePressed) {
        cmds.kicks[i] = PVector.sub(ball.position, myTeam.positions[i]);
      }
    }
    return cmds;
  }
}

