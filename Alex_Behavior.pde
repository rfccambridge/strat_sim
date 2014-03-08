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
    int matcher=1;//index of opposite player
    //while(matcher<otherTeam.n){
      for (int i=1; i<n; i++) {
        PVector newPos;
        //directions for player closest to ball
        if(i==closestTeamPlayer&&ball.position.y>fieldWidth/2){
        // set x coordinate to be halfway between ball and goal, y coord between goal midpoint and ball
        newPos = ball.position;
        // can't be in goalie area
        if (this.side && newPos.x > ((7.0/8)*this.fieldWidth)) {
          newPos.x = (7.0/8)*this.fieldWidth;
        }
        else if (!this.side && newPos.x < ((1.0/8)*this.fieldWidth)) {
          newPos.x = (1.0/8)*this.fieldWidth;
        }
        /*if (this.wall) {
          newPos.y += (i-(n-1)/2.0) * 2 * robotRadius; // stagger robots in vertical wall
        }*/
        }
        else if(i==closestTeamPlayer-1&&otherTeam.positions[closestOtherPlayer].x>this.fieldWidth/4){
          newPos=PVector.add(PVector.mult(otherTeam.positions[closestOtherPlayer],.25),PVector.mult(otherTeam.positions[closestOtherPlayer-1],.75));
        }
        //directions for rest of team
        else{
          float backposition=0;
          for(int j=1; j<otherTeam.n;j++){
            if(backposition<otherTeam.positions[j].x){
              backposition = otherTeam.positions[j].x;
            }
        }
        float x = max(this.fieldWidth*2/3, backposition);
        float y= fieldHeight/2+(this.fieldWidth-x)/(this.fieldWidth*1.0/4)*(float)(i-3)/4*(fieldHeight/2);
        newPos= new PVector(x,y);
      }
      
      cmds.targets[i] = newPos;//call to indicator robot
      if(ball.position.y>fieldHeight/2){
      cmds.kicks[i] = PVector.sub(new PVector(0,fieldHeight), myTeam.positions[i]);//generates kicking positions of robots
      }
      else{
        cmds.kicks[i]= PVector.sub(new PVector(0,0), myTeam.positions[i]);
      }
    }
    //}
       
    // Goalie robot
    PVector goaliePos = new PVector(fieldWidth, fieldHeight/2);
    if (ball.position.x>fieldWidth/2){
      goaliePos= PVector.add(PVector.mult(ball.position,.5),PVector.mult(new PVector(fieldWidth, fieldHeight/2),.5));
    }
    cmds.targets[0] = goaliePos;
    cmds.kicks[0] = PVector.sub(new PVector(fieldWidth/2,0), myTeam.positions[0]);
    return cmds;
  }
}
