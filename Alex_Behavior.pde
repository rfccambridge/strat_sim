class BehaveAlexDefense extends BehaveBlockDefense {
  public BehaveAlexDefense(Boolean side_, float fieldWidth_, float fieldHeight_, float goalTop_, float goalBottom_) {
    super(side_, false, fieldWidth_, fieldHeight_, goalTop_, goalBottom_);
  }
  
  public int proximaTeam(Team team, Ball ball) {//returns index of closest team player to ball
    int closestPlayer=1;
    for(int i=1;i<team.n; i++){
      if((PVector.sub(team.positions[i],ball.position).mag())<(PVector.sub(team.positions[closestPlayer],ball.position)).mag()){
        closestPlayer=i;
      }
    }
      return closestPlayer;
  }
  public int proximaOther(Team team, Ball ball){//returns index of closest opponent player to ball
    int closestPlayer=1;
    for(int i=2;i<team.n; i++){
      if((PVector.sub(team.positions[i],ball.position)).mag()<(PVector.sub(team.positions[closestPlayer],ball.position)).mag()){
        closestPlayer=i;
      }
    }
      return closestPlayer;
  }
  
    public CmdSet update(Team myTeam, Team otherTeam, Ball ball) {
    int n = myTeam.n;
    CmdSet cmds = new CmdSet(n);
    
    // Calculate vector between ball and goal
    PVector v = PVector.sub(goalMid, ball.position);
    float ballToGoal = v.mag();
    v.limit(ballToGoal / 2);
    //index of closest team player to ball
    int closestTeamPlayer= this.proximaTeam(myTeam, ball);
    //index of closest opponent to ball
    int closestOtherPlayer=this.proximaOther(otherTeam, ball);
    
        // Non goalie robots
    for (int i=1; i<n; i++) {
      PVector newPos;
      //directions for player closest to ball
      if(i==closestTeamPlayer&&ball.position.mag()>this.fieldWidth/2){
      // set x coordinate to be halfway between ball and goal, y coord between goal midpoint and ball
      newPos = PVector.add(ball.position, v);
      // can't be in goalie area
      if (this.side && newPos.x > ((7.0/8)*this.fieldWidth)) {
        newPos.x = (7.0/8)*this.fieldWidth;
      } else if (!this.side && newPos.x < ((1.0/8)*this.fieldWidth)) {
        newPos.x = (1.0/8)*this.fieldWidth;
      }
      if (this.wall) {
        newPos.y += (i-(n-1)/2.0) * 2 * robotRadius; // stagger robots in vertical wall
      }
      }
      else{
        float backposition=0;
        for(int j=1; j<otherTeam.n;i++){
          if(backposition<otherTeam.positions[j].y){
            backposition = otherTeam.positions[j].y;
          }
        }
        newPos= new PVector(max(this.fieldWidth*6/8, backposition),this.fieldHeight*(float)i/6);
      }
      
      cmds.targets[i] = newPos;//call to indicator robot
      cmds.kicks[i] = PVector.sub(otherGoalMid, myTeam.positions[i]);//generates kicking positions of robots
      }
        
    // Goalie robot
    PVector goaliePos = ball.position.get();
    if (this.side && goaliePos.x < (7.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (7.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    } else if (!this.side && goaliePos.x > (1.0/8)*this.fieldWidth) {
      float distToGoalBox = abs(goaliePos.x - (1.0/8)*this.fieldWidth);
      v.setMag(abs((distToGoalBox / v.x) * v.mag()));
      goaliePos.add(v);
    }
    cmds.targets[0] = goaliePos;
    cmds.kicks[0] = PVector.sub(otherGoalMid, myTeam.positions[0]);
    return cmds;
  }
}
