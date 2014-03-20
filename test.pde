class BehaveNothing extends Behavior {

  // true means goal is on right
  public BehaveNothing(Boolean side) {
    super(side);
  }
  
  public void reset(String msg) {
  }

  public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);

    for (int i=0; i<n; i++) {
      cmds.targets[i] = myTeam.positions[i];
    }
    return cmds;
  }
}
