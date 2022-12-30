///////////////////////////////////////////////////////////////////////////
//
// New Messages
//
// 
///////////////////////////////////////////////////////////////////////////

final int CONNEXION_LAUNCHER = 5;
final int CONNEXION_DEFENDER = 6;
final int CONFIRM_CONNEXION = 7;
final int ABORT_CONNEXION = 8;
final int BACK_TO_BASE = 9;
final int UPDATE_DIRECTION = 10;
final int HEART_BEAT = 11;
final int PROMUTE_SQUAD_LEADER = 12;
final int CONNEXION_SQUAD = 13;
final int SEARCH_LAUNCHER_NO_ROLE = 14;
final int FREE = 15;
final int ATTACK_TARGET = 16;
final int FIND_BASE = 17;

///////////////////////////////////////////////////////////////////////////
//
// New Roles
//
//
///////////////////////////////////////////////////////////////////////////

final float NO_ROLE = 0f;
final float HARVEST_ROLE = 1f;
final float DEFEND_ROLE = 2f;
final float SQUAD_LEADER = 3f;
final float SQUAD_SOLDIER = 4f;
final float WAITING_ROLE = 5f;

final float[] EMPTY_ARGS = new float[0];

///////////////////////////////////////////////////////////////////////////
//
// The code for the red team
// ===========================
//
///////////////////////////////////////////////////////////////////////////

class RedTeam extends Team {
  final int MY_CUSTOM_MSG = 5;
  PVector base1, base2;

  // coordinates of the 2 bases, chosen in the rectangle with corners
  // (width/2, 0) and (width, height-100)
  RedTeam() {
    // first base
    base1 = new PVector(width/2 + 300, (height - 100)/2 - 150);
    // second base
    base2 = new PVector(width/2 + 300, (height - 100)/2 + 150);
  }  
}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green bases
//
///////////////////////////////////////////////////////////////////////////
class RedBase extends Base {
  //
  // constructor
  // ===========
  //
  RedBase(PVector p, color c, Team t) {
    super(p, c, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the base
  //
  void setup() {
    // Set we have 0 defender
    brain[0].x = -1;
    brain[0].y = -1;
    brain[0].z = -1;

    brain[1].x = 0; // Indicateur pour la création à reset à 0 une fois l'action fini
    brain[1].y = 0; // Code qui indique quelle action on effectu : 0 rien , 1 création d'une squad, 2 création squad harvester, ...
    brain[1].z = 0; // Indicateur pour la création à reset à 0 une fois l'action fini

    // Ennemy base 1 pos
    brain[2].x = -1;
    brain[2].y = -1;
    // Ennemy base 2 pos
    brain[2].z = -1;
    brain[3].x = -1;

    brain[5].x = 0;
    brain[5].y = 2;
    brain[5].z = 0;
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    // Check defenders are still alive
    //checkDefendersAlive();
    // handle received messages 
    handleMessages();

    //if(needDefender())
      //searchRocketLauncher();

    // creates new robots depending on energy and the state of brain[5]
    /*if ((brain[5].x > 0) && (energy >= 1000 + harvesterCost)) {
      // 1st priority = creates harvesters 
      if (newHarvester()){
        brain[1].z = 1;
        brain[5].x--;
      }
    } else if ((brain[5].y > 0) && (energy >= 1000 + launcherCost)) {
      // 2nd priority = creates rocket launchers 
      if (newRocketLauncher()){
        brain[1].z = 1;
        brain[5].y--;
      }
    } else if ((brain[5].z > 0) && (energy >= 1000 + explorerCost)) {
      // 3rd priority = creates explorers 
      if (newExplorer()){
        brain[1].z = 1;
        brain[5].z--;
      }
    } */

    if (energy > 4*1000 + 4*launcherCost && brain[1].y == 0) {
      brain[1].y = 1;
    }

    if(energy > 2*1000+ launcherCost+harvesterCost && brain[1].y == 0){
      brain[1].y = 2;
    }

    

    
    
    if(brain[1].y == 1){
      createSquad();
    }
    else if(brain[1].y == 2){
      createHarvesterSquad();
    }
    
      /*else if (energy > 12000) {
      // if no robot in the pipe and enough energy 
      if ((int)random(2) == 0)
        // creates a new harvester with 50% chance
        brain[5].x++;
      else if ((int)random(2) == 0)
        // creates a new rocket launcher with 25% chance
        brain[5].y++;
      else
        // creates a new explorer with 25% chance
        brain[5].z++;
    }*/

    // creates new bullets and fafs if the stock is low and enought energy
    if ((bullets < 10) && (energy > 1000))
      newBullets(50);
    if ((bullets < 10) && (energy > 1000))
      newFafs(10);

    // if ennemy rocket launcher in the area of perception
    Robot bob = (Robot)minDist(perceiveRobots(ennemy, LAUNCHER));
    if (bob != null) {
      heading = towards(bob);
      // launch a faf if no friend robot on the trajectory...
      if (perceiveRobotsInCone(friend, heading) == null)
        launchFaf(bob);

      // Inform defenders
      if(brain[0].x != -1) informAboutTarget((int) brain[0].x, bob);
      if(brain[0].y != -1) informAboutTarget((int) brain[0].y, bob);
      if(brain[0].z != -1) informAboutTarget((int) brain[0].z, bob);
    }

    
  }

  void createHarvesterSquad(){
    if(brain[1].x == 0){
      if(newHarvester()){
        brain[1].x += 1;
      }
    }
    else{
      if(newRocketLauncher()){
        brain[1].x = 0;
        brain[1].y = 0;
      }
    }
  }

  void createSquad(){
    if(brain[1].x == 0){
      //Send message to know how many launcher are free
      searchLauncher();
      brain[1].x = 1;
    } else if(brain[1].x == 1){
      //Waiting 1 round
      brain[1].x = 2;
    } else if(brain[1].x == 2 && brain[1].z <= 3){
      if(newRocketLauncher()){
        if(brain[1].z == 0){ // No free launcher
          println("ERROR", brain[1].z);
          searchSquadLeader();
        }
        brain[1].z += 1;
        println("TEST", brain[1].z);
      }
    } 
    else {
      brain[1].x = 0;
      brain[1].y = 0; //TODO : change 0
      brain[1].z = 0;
    }
  }

  void searchLauncher() {
    ArrayList lauchers = perceiveRobots(friend, LAUNCHER);

    if(lauchers != null) {
      for(int i = 0; i < lauchers.size(); i++) {
        sendMessage((Robot)lauchers.get(i), SEARCH_LAUNCHER_NO_ROLE, EMPTY_ARGS);
      }
    }
  }

  void searchSquadLeader() {
    ArrayList lauchers = perceiveRobots(friend, LAUNCHER);

    if(lauchers != null) {
      for(int i = 0; i < lauchers.size(); i++) {
        sendMessage((Robot)lauchers.get(i), PROMUTE_SQUAD_LEADER, new float[]{brain[2].x, brain[2].y, brain[2].z, brain[3].x});
      }
    }
  }

  void searchRocketLauncher() {
    ArrayList lauchers = perceiveRobots(friend, LAUNCHER);

    if(lauchers != null) {
      for(int i = 0; i < lauchers.size(); i++) {
        sendMessage((Robot)lauchers.get(i), CONNEXION_DEFENDER, EMPTY_ARGS);
      }
    }
  }

  // UNUSED
  /*void driveDefenders() {
    Robot target = null;

    // Search ennemy
    ArrayList robots = perceiveRobots(ennemy, LAUNCHER);
    if(robots != null && robots.size() > 0)
      target = (Robot) robots.get(0);
    else {
      robots = perceiveRobots(ennemy, HARVESTER);
      if(robots != null && robots.size() > 0)
        target = (Robot) robots.get(0);
      else {
        robots = perceiveRobots(ennemy, EXPLORER);
        if(robots != null && robots.size() > 0)
          target = (Robot) robots.get(0);
      }
    }

    // Ennemy found
    if(target != null) {
      float[] args = new float[]{target.pos.x, target.pos.y};
      if(brain[0].x != -1) sendMessage((int) brain[0].x, ATTACK_TARGET, args);
      if(brain[0].y != -1) sendMessage((int) brain[0].y, ATTACK_TARGET, args);
      if(brain[0].z != -1) sendMessage((int) brain[0].z, ATTACK_TARGET, args);
    }
  }*/

  //
  // handleMessage
  // =============
  // > handle messages received since last activation 
  //
  void handleMessages() {
    Message msg;
    // for all messages
    for (int i=0; i<messages.size(); i++) {
      msg = messages.get(i);
      
      // Check message is from ally
      Robot transmitter = game.getRobot(msg.alice);
      if(transmitter != null && transmitter.colour != friend) continue;
      
      if (msg.type == ASK_FOR_ENERGY) {
        // if the message is a request for energy
        if (energy > 1000 + msg.args[0]) {
          // gives the requested amount of energy only if at least 1000 units of energy left after
          giveEnergy(msg.alice, msg.args[0]);
        }
      } else if (msg.type == ASK_FOR_BULLETS) {
        // if the message is a request for energy
        if (energy > 1000 + msg.args[0] * bulletCost) {
          // gives the requested amount of bullets only if at least 1000 units of energy left after
          giveBullets(msg.alice, msg.args[0]);
        }
      } // if "confirm connexion" message
      else if(msg.type == CONFIRM_CONNEXION) {
        if(needDefender()) {
          setDefender((float) msg.alice);
          sendMessage(msg.alice, CONFIRM_CONNEXION, new float[]{DEFEND_ROLE});
        } else {
          sendMessage(msg.alice, ABORT_CONNEXION, EMPTY_ARGS);
        }
      } // Si on recherche de quoi créer un squad
      else if(brain[1].y == 1 && msg.type == FREE) {
        if(brain[1].z == 0){ // Transform into leader
          sendMessage(msg.alice, PROMUTE_SQUAD_LEADER, new float[]{brain[2].x, brain[2].y, brain[2].z, brain[3].x});
          brain[1].z += 1;
        } else {
          brain[1].z += 1;
          sendMessage(msg.alice, ABORT_CONNEXION, EMPTY_ARGS);
        }
      }
      else if(msg.type == FIND_BASE){
        if(brain[2].x == -1) {
          brain[2].x = msg.args[0];
          brain[2].y = msg.args[1];
        } else if(brain[2].z == -1 && (brain[2].x != msg.args[0] || brain[2].y != msg.args[1])){
          brain[2].z = msg.args[0];
          brain[3].x = msg.args[1];
        }
      }
    }
    // clear the message queue
    flushMessages();
  }

  void checkDefendersAlive() {
    ArrayList launchers = perceiveRobots(friend, LAUNCHER);
    boolean[] alive = new boolean[]{false, false, false};

    if(launchers != null) {
      for(int i = 0; i < launchers.size(); i++) {
        RocketLauncher launcher = (RocketLauncher) launchers.get(i);
        int defender = getDefender((float) launcher.who);

        if(defender >= 0) alive[defender] = true;
      }
    }

    if(!alive[0]) {
      brain[0].x = -1;
      brain[5].y++;
    }

    if(!alive[1]) {
      brain[0].y = -1;
      brain[5].y++;
    }

    if(!alive[2]) {
      brain[0].z = -1;
      brain[5].y++;
    }
  }

  boolean needDefender() {
    return brain[0].x == -1 || brain[0].y == -1 || brain[0].z == -1;
  }

  int getDefender(float id) {
    if (brain[0].x == id) return 0;
    if (brain[0].y == id) return 1;
    if (brain[0].z == id) return 2;
    return -1;
  }

  int setDefender(float id) {
    if (brain[0].x == -1) {
      brain[0].x = id;
      return 0;
    }

    if (brain[0].y == -1) {
      brain[0].y = id;
      return 1;
    }

    if (brain[0].z == -1) {
      brain[0].z = id;
      return 2;
    }
    
    return -1;
  }
}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green explorers
//
///////////////////////////////////////////////////////////////////////////
// map of the brain:
//   4.x = (0 = exploration | 1 = go back to base)
//   4.y = (0 = no target | 1 = locked target)
//   0.x / 0.y = coordinates of the target
//   0.z = type of the target
///////////////////////////////////////////////////////////////////////////
class RedExplorer extends Explorer {
  //
  // constructor
  // ===========
  //
  RedExplorer(PVector pos, color c, ArrayList b, Team t) {
    super(pos, c, b, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the agent
  //
  void setup() {
    // Ennemy base 1 pos
    brain[0].x = -1;
    brain[0].y = -1;
    // Ennemy base 2 pos
    brain[0].z = -1;
    brain[1].x = -1;
    // Food pos slot 1
    brain[1].y = -1;
    brain[1].z = -1;
    // Food pos slot 2
    brain[2].x = -1;
    brain[2].y = -1;
    // Food pos slot 3
    brain[2].z = -1;
    brain[3].x = -1;
    // Ennemy pos slot 1
    brain[3].y = -1;
    brain[3].z = -1;
    // Food pos index
    brain[4].y = 0;
    // Ennemy pos index
    brain[4].z = 0;
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
 void go() {
    // if food to deposit or too few energy
    if ((carryingFood > 200) || (energy < 100))
      // time to go back to base
      brain[4].x = 1;

    // depending on the state of the robot
    if (brain[4].x == 1) {
      // go back to base...
      goBackToBase();
    } else {
      // ...or explore randomly
      randomMove(45);
    }

    // tries to localize ennemy bases
    //lookForEnnemyBase();
    // inform harvesters about food sources
    //driveHarvesters();
    // inform rocket launchers about targets
    //driveRocketLaunchers();

    // Locate ennemy base
    locateEnnemyBase();
    // Locate food
    locateFood();

    // Notify allies about info we get
    notifyBase();
    notifyExplorer();
    notifyHarvesters();
    notifyRocketLaunchers();

    // give wrong information to ennemies
    baitEnnemies();

    // clear the message queue
    flushMessages();
  }

  void locateEnnemyBase() {
    if(brain[0].x != -1 && brain[0].z != -1) return;

    ArrayList bases = perceiveRobots(ennemy, BASE);

    if(bases != null) {
      for(int i = 0; i < bases.size(); i++) {
        PVector pos = ((Base) bases.get(i)).pos;
        if(brain[0].x == -1) {
          brain[0].x = pos.x;
          brain[0].y = pos.y;
          brain[4].x = 1; // Back to Base
        } else if(brain[0].z == -1 && (brain[0].x != pos.x || brain[0].y != pos.y)){
          brain[0].z = pos.x;
          brain[1].x = pos.y;
          brain[4].x = 1; // Back to Base
        }
      }
    }
  }

  void locateFood() {
    Burger zorg = (Burger)oneOf(perceiveBurgers());
    if (zorg != null) {
      if(brain[4].y == 0) {
        brain[1].y = zorg.pos.x;
        brain[1].z = zorg.pos.y;
      } else if(brain[4].y == 1) {
        brain[2].x = zorg.pos.x;
        brain[2].y = zorg.pos.y;
      } else if(brain[4].y == 2) {
        brain[2].z = zorg.pos.x;
        brain[3].x = zorg.pos.y;
      }
    }

    brain[4].y = brain[4].y == 2 ? 0 : brain[4].y + 1;
  }

  void notifyExplorer(){
    ArrayList explorers = perceiveRobots(friend, EXPLORER);
    PVector bases[] = new PVector[]{
      new PVector(brain[0].x, brain[0].y),
      new PVector(brain[0].z, brain[1].x)
      };

    if(explorers != null) {
      for(int i = 0; i < explorers.size(); i++) {
        for(int j = 0; j < bases.length; j++) {
          if(bases[j].x != -1) {
            sendMessage((Explorer) explorers.get(i), FIND_BASE, new float[]{bases[j].x, bases[j].y});
          }
        }
      }
    }
  }

  void notifyBase(){
    ArrayList bases2 = perceiveRobots(friend, BASE);
    PVector bases[] = new PVector[]{
      new PVector(brain[0].x, brain[0].y),
      new PVector(brain[0].z, brain[1].x)
      };

    if(bases2 != null) {
      for(int i = 0; i < bases2.size(); i++) {
        for(int j = 0; j < bases.length; j++) {
          if(bases[j].x != -1) {
            sendMessage((Explorer) bases2.get(i), FIND_BASE, new float[]{bases[j].x, bases[j].y});
          }
        }
      }
    }
  }

  void notifyHarvesters() {
    ArrayList harvesters = perceiveRobots(friend, HARVESTER);
    PVector food[] = new PVector[]{
      new PVector(brain[1].y, brain[1].z), 
      new PVector(brain[2].x, brain[2].y), 
      new PVector(brain[2].z, brain[3].x)
      };

    if(harvesters != null) {
      for(int i = 0; i < harvesters.size(); i++) {
        for(int j = 0; j < food.length; j++) {
          if(food[j].x != -1) {
            informAboutFood((Harvester) harvesters.get(i), food[j]);
          }
        }
      }
    }
  }

  void notifyRocketLaunchers() {
    ArrayList launchers = perceiveRobots(friend, LAUNCHER);
    PVector bases[] = new PVector[]{
      new PVector(brain[0].x, brain[0].y),
      new PVector(brain[0].z, brain[1].x)
      };

    if(launchers != null) {
      for(int i = 0; i < launchers.size(); i++) {
        for(int j = 0; j < bases.length; j++) {
          if(bases[j].x != -1) {
            sendMessage(
              (RocketLauncher) launchers.get(i), 
              INFORM_ABOUT_XYTARGET, 
              new float[]{BASE, bases[j].x, bases[j].y});
          }
        }
      }
    }
  }

  void baitEnnemies() {
    ArrayList ennemies;
    PVector baitPos = new PVector(random(255), random(255), random(255));
    Harvester baitHarvester = (Harvester)oneOf(perceiveRobots(ennemy, HARVESTER));

    ennemies = perceiveRobots(ennemy, EXPLORER);
    if(ennemies != null) {
      for(int i = 0; i < ennemies.size(); i++) {
        informAboutFood((Explorer) ennemies.get(i), baitPos);
      }
    }
    
    ennemies = perceiveRobots(ennemy, HARVESTER);
    if(ennemies != null) {
      for(int i = 0; i < ennemies.size(); i++) {
        informAboutFood((Harvester) ennemies.get(i), baitPos);
      }
    }
    
    if(baitHarvester != null){
      ennemies = perceiveRobots(ennemy, LAUNCHER);
      if(ennemies != null) {
        for(int i = 0; i < ennemies.size(); i++) {
          informAboutTarget((RocketLauncher) ennemies.get(i), baitHarvester);
        }
      }
    }
  }

  //
  // setTarget
  // =========
  // > locks a target
  //
  // inputs
  // ------
  // > p = the location of the target
  // > breed = the breed of the target
  //
  void setTarget(PVector p, int breed) {
    brain[0].x = p.x;
    brain[0].y = p.y;
    brain[0].z = breed;
    brain[4].y = 1;
  }

  //
  // goBackToBase
  // ============
  // > go back to the closest base, either to deposit food or to reload energy
  //
  void goBackToBase() {
    // bob is the closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      // if there is one (not all of my bases have been destroyed)
      float dist = distance(bob);

      if (dist <= 2) {
        // if I am next to the base
        if (energy < 500)
          // if my energy is low, I ask for some more
          askForEnergy(bob, 1500 - energy);
        // switch to the exploration state
        brain[4].x = 0;
        // make a half turn
        right(180);
      } else {
        // if still away from the base
        // head towards the base (with some variations)...
        heading = towards(bob) + random(-radians(20), radians(20));
        // ...and try to move forward 
        tryToMoveForward();
      }
    }
  }

  //
  // handleMessages
  // ==============
  // > handle messages received
  // > identify the closest localized burger
  //
  void handleMessages() {
    float d = width;
    PVector p = new PVector();

    Message msg;
    // for all messages
    for (int i=0; i<messages.size(); i++) {
      // get next message
      msg = messages.get(i);
      
      // Check message is from ally
      Robot transmitter = game.getRobot(msg.alice);
      if(transmitter != null && transmitter.colour != friend) continue;
      
      // if "localized base" message
      if (msg.type == FIND_BASE) {
        if(brain[0].x == -1) {
          brain[0].x = msg.args[0];
          brain[0].y = msg.args[1];
        } else if(brain[0].z == -1 && (brain[0].x != msg.args[0] || brain[0].y != msg.args[1])){
          brain[0].z = msg.args[0];
          brain[1].x = msg.args[1];
        }
      }
    }
  }
  

  //
  // target
  // ======
  // > checks if a target has been locked
  //
  // output
  // ------
  // true if target locket / false if not
  //
  boolean target() {
    return (brain[4].y == 1);
  }

  //
  // driveHarvesters
  // ===============
  // > tell harvesters if food is localized
  //
  void driveHarvesters() {
    // look for burgers
    Burger zorg = (Burger)oneOf(perceiveBurgers());
    if (zorg != null) {
      // if one is seen, look for a friend harvester
      Harvester harvey = (Harvester)oneOf(perceiveRobots(friend, HARVESTER));
      if (harvey != null)
        // if a harvester is seen, send a message to it with the position of food
        informAboutFood(harvey, zorg.pos);
    }
  }

  //
  // driveRocketLaunchers
  // ====================
  // > tell rocket launchers about potential targets
  //
  void driveRocketLaunchers() {
    // look for an ennemy robot 
    Robot bob = (Robot)oneOf(perceiveRobots(ennemy));
    if (bob != null) {
      // if one is seen, look for a friend rocket launcher
      RocketLauncher rocky = (RocketLauncher)oneOf(perceiveRobots(friend, LAUNCHER));
      if (rocky != null)
        // if a rocket launcher is seen, send a message with the localized ennemy robot
        informAboutTarget(rocky, bob);
    }
  }

  //
  // lookForEnnemyBase
  // =================
  // > try to localize ennemy bases...
  // > ...and to communicate about this to other friend explorers
  //
  void lookForEnnemyBase() {
    // look for an ennemy base
    Base babe = (Base)oneOf(perceiveRobots(ennemy, BASE));
    if (babe != null) {
      // if one is seen, look for a friend explorer
      Explorer explo = (Explorer)oneOf(perceiveRobots(friend, EXPLORER));
      if (explo != null)
        // if one is seen, send a message with the localized ennemy base
        informAboutTarget(explo, babe);
      // look for a friend base
      Base basy = (Base)oneOf(perceiveRobots(friend, BASE));
      if (basy != null)
        // if one is seen, send a message with the localized ennemy base
        informAboutTarget(basy, babe);
    }
  }

  //
  // tryToMoveForward
  // ================
  // > try to move forward after having checked that no obstacle is in front
  //
  void tryToMoveForward() {
    // if there is an obstacle ahead, rotate randomly
    if (!freeAhead(speed))
      right(random(360));

    // if there is no obstacle ahead, move forward at full speed
    if (freeAhead(speed))
      forward(speed);
  }
}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green harvesters
//
///////////////////////////////////////////////////////////////////////////
// map of the brain:
//   4.x = (0 = look for food | 1 = go back to base) 
//   4.y = (0 = no food found | 1 = food found)
//   0.x / 0.y = position of the localized food
///////////////////////////////////////////////////////////////////////////
class RedHarvester extends Harvester {
  //
  // constructor
  // ===========
  //
  RedHarvester(PVector pos, color c, ArrayList b, Team t) {
    super(pos, c, b, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the agent
  //
  void setup() {
    brain[3].x = -1;
    brain[4].z = 0;
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    // handle messages received
      handleMessages();
    if(brain[4].z == NO_ROLE){
      // send message to search RocketLauncher to connect with
      goBackToBase();
      searchRocketLauncher();
    }
    else{
      // check for the closest burger
      Burger b = (Burger)minDist(perceiveBurgers());
      if ((b != null) && (distance(b) <= 2))
        // if one is found next to the robot, collect it
        takeFood(b);

      // if food to deposit or too few energy
      if ((carryingFood > 200) || (energy < 100))
        // time to go back to the base
        brain[4].x = 1;

      // Back to base if loose contact with rocket launcher
      if(brain[4].z != NO_ROLE && looseTeam())
        brain[4].x = 1;

      // if in "go back" state
      if (brain[4].x == 1) {
        // go back to the base
        goBackToBase();

        // if enough energy and food
        if ((energy > 100) && (carryingFood > 100)) {
          // check for closest base
          Base bob = (Base)minDist(myBases);
          if (bob != null) {
            // if there is one and the harvester is in the sphere of perception of the base
            if (distance(bob) < basePerception)
              // plant one burger as a seed to produce new ones
              plantSeed();
          }
        }
      } else
        // if not in the "go back" state, explore and collect food
        goAndEat();

      // Notify direction to rocket launcher
      sendMessage((int) brain[3].x, UPDATE_DIRECTION, new float[]{heading, speed});
    }
  }

  boolean looseTeam() {
    Robot teamate = game.getRobot((int) brain[3].x);

    return teamate == null || distance(teamate) > messageRange;
  }

  //
  // goBackToBase
  // ============
  // > go back to the closest friend base
  //
  void goBackToBase() {
    // look for the closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      // if there is one
      float dist = distance(bob);
      if ((dist > basePerception) && (dist < basePerception + 1))
        // if at the limit of perception of the base, drops a wall (if it carries some)
        dropWall();

      if (dist <= 2) {
        if(looseTeam())
          brain[4].z = NO_ROLE;

        // if next to the base, gives the food to the base
        giveFood(bob, carryingFood);
        if (energy < 500)
          // ask for energy if it lacks some
          askForEnergy(bob, 1500 - energy);
        // go back to "explore and collect" mode
        brain[4].x = 0;
        // make a half turn
        right(180);
      } else {
        // if still away from the base
        // head towards the base (with some variations)...
        heading = towards(bob) + random(-radians(20), radians(20));
        // ...and try to move forward
        tryToMoveForward();
      }
    }
  }

  //
  // goAndEat
  // ========
  // > go explore and collect food
  //
  void goAndEat() {
    // look for the closest wall
    Wall wally = (Wall)minDist(perceiveWalls());
    // look for the closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      float dist = distance(bob);
      // if wall seen and not at the limit of perception of the base 
      if ((wally != null) && ((dist < basePerception - 1) || (dist > basePerception + 2)))
        // tries to collect the wall
        takeWall(wally);
    }

    // look for the closest burger
    Burger zorg = (Burger)minDist(perceiveBurgers());
    if (zorg != null) {
      // if there is one
      if (distance(zorg) <= 2)
        // if next to it, collect it
        takeFood(zorg);
      else {
        // if away from the burger, head towards it...
        heading = towards(zorg) + random(-radians(20), radians(20));
        // ...and try to move forward
        tryToMoveForward();
      }
    } else if (brain[4].y == 1) {
      // if no burger seen but food localized (thank's to a message received)
      if (distance(brain[0]) > 2) {
        // head towards localized food...
        heading = towards(brain[0]);
        // ...and try to move forward
        tryToMoveForward();
      } else {
        // if the food is reached and no found, clear the corresponding flag
        // else keep this destination in mind
        zorg = (Burger)minDist(perceiveBurgers());
        brain[4].y = zorg != null ? 1 : 0;
      }
    } else {
      // if no food seen and no food localized, explore randomly
      heading += random(-radians(45), radians(45));
      tryToMoveForward();
    }
  }

  //
  // tryToMoveForward
  // ================
  // > try to move forward after having checked that no obstacle is in front
  //
  void tryToMoveForward() {
    // if there is an obstacle ahead, rotate randomly
    if (!freeAhead(speed))
      right(random(360));

    // if there is no obstacle ahead, move forward at full speed
    if (freeAhead(speed))
      forward(speed);
  }

  //
  // handleMessages
  // ==============
  // > handle messages received
  // > identify the closest localized burger
  //
  void handleMessages() {
    float d = width;
    PVector p = new PVector();

    Message msg;
    // for all messages
    for (int i=0; i<messages.size(); i++) {
      // get next message
      msg = messages.get(i);
      
      // Check message is from ally
      Robot transmitter = game.getRobot(msg.alice);
      if(transmitter != null && transmitter.colour != friend) continue;
      
      // if "localized food" message
      if (msg.type == INFORM_ABOUT_FOOD) {
        // record the position of the burger
        p.x = msg.args[0];
        p.y = msg.args[1];
        if (distance(p) < d) {
          // if burger closer than closest burger
          // record the position in the brain
          brain[0].x = p.x;
          brain[0].y = p.y;
          // update the distance of the closest burger
          d = distance(p);
          // update the corresponding flag
          brain[4].y = 1;
        }
      } // if "confirm connexion" message
      else if(msg.type == CONFIRM_CONNEXION && brain[3].x == -1) {
        brain[3].x = msg.alice;
        brain[4].z = HARVEST_ROLE;
        sendMessage(msg.alice, CONFIRM_CONNEXION, new float[]{HARVEST_ROLE});
      }
      else if(msg.type == CONFIRM_CONNEXION && brain[3].x != -1) {
        sendMessage(msg.alice, ABORT_CONNEXION, EMPTY_ARGS);
      }
      else if(msg.type == BACK_TO_BASE && brain[3].x != -1) {
        brain[4].x = 1;
      }
    }
    // clear the message queue
    flushMessages();
  }

  void searchRocketLauncher() {
    ArrayList lauchers = perceiveRobots(friend, LAUNCHER);

    if(lauchers != null) {
      for(int i = 0; i < lauchers.size(); i++) {
        sendMessage((Robot)lauchers.get(i), CONNEXION_LAUNCHER, EMPTY_ARGS);
      }
    }
  }

}

///////////////////////////////////////////////////////////////////////////
//
// The code for the green rocket launchers
//
///////////////////////////////////////////////////////////////////////////
// map of the brain:
//   0.x / 0.y = position of the target
//   0.z = breed of the target
//   4.x = (0 = look for target | 1 = go back to base) 
//   4.y = (0 = no target | 1 = localized target)
///////////////////////////////////////////////////////////////////////////
class RedRocketLauncher extends RocketLauncher {
  //
  // constructor
  // ===========
  //
  RedRocketLauncher(PVector pos, color c, ArrayList b, Team t) {
    super(pos, c, b, t);
  }

  //
  // setup
  // =====
  // > called at the creation of the agent
  //
  void setup() {
    brain[3].x = -1;
    brain[4].z = NO_ROLE;
    brain[2].x = -1;
    brain[2].y = -1;
    brain[2].z = -1;
  }

  //
  // go
  // ==
  // > called at each iteration of the game
  // > defines the behavior of the agent
  //
  void go() {
    // handle messages received
    handleMessages();
    if(brain[4].z == SQUAD_LEADER && (brain[2].x == -1 || brain[2].y == -1 || brain[2].z == -1)){
      //Search until squad is full
      searchSquadSoldier();
    }
    else {
      // if no energy or no bullets
      if ((energy < 100) || (bullets == 0))
        // go back to the base
        brain[4].x = 1;

      // Back to base if loose contact with :
      // - harvester if HARVEST_ROLE
      // - base if DEFEND_ROLE
      // - squad leader if SQUAD_SOLDIER
      if((brain[4].z == HARVEST_ROLE || brain[4].z == SQUAD_SOLDIER) && looseTeam())
        brain[4].x = 1;

      Base base = (Base) minDist(perceiveRobots(friend, BASE));
      if(brain[4].z == WAITING_ROLE || (brain[4].z == NO_ROLE && (base == null || distance(base) > messageRange)))
        brain[4].x = 1;

      if (brain[4].x == 1) {
        // if in "go back to base" mode
        goBackToBase();
      } else {

        // try to find a target
        if(brain[4].y != 2)
          selectTarget();
        
        // Follow harvester
        if(brain[4].z == HARVEST_ROLE || brain[4].z == SQUAD_SOLDIER) {
          heading = brain[3].y;
          forward(brain[3].z);

          if(brain[4].z == HARVEST_ROLE)
            // If burger seen, tell ally harvester
            driveHarvester();

          // if target identified
          if (target())
            // shoot on the target
            launchBullet(towards(brain[0]));
        } else if(brain[4].z == SQUAD_LEADER){
          // Notify direction to rocket launcher
          sendMessage((int) brain[2].x, UPDATE_DIRECTION, new float[]{heading, speed});
          sendMessage((int) brain[2].y, UPDATE_DIRECTION, new float[]{heading, speed});
          sendMessage((int) brain[2].z, UPDATE_DIRECTION, new float[]{heading, speed});
          forward(speed);

          // if target identified
          if (target())
            // shoot on the target
            launchBullet(towards(brain[0]));
            
        } else if(brain[4].z == DEFEND_ROLE || brain[4].z == NO_ROLE) {
          // if target identified
          if (target()) {
            // Follow the target
            if(distance(brain[0]) > 5) {
              right(towards(brain[0]));
              forward(speed);
            } else {
              // If no robot found at position given by base, reset flag
              ArrayList robots = perceiveRobots(ennemy, LAUNCHER);
              if(robots == null || robots.size() == 0)
                brain[4].y = 0;
            }
            // shoot on the target
            launchBullet(towards(brain[0]));
          } else {
            // Move randomly in base
            //randomMove(90f);
            heading += random(-radians(45f), radians(45f));
            forward(0.3f);
          }
        }
      }
    }
  }

  void searchSquadSoldier() {
    ArrayList lauchers = perceiveRobots(friend, LAUNCHER);

    if(lauchers != null) {
      for(int i = 0; i < lauchers.size(); i++) {
        sendMessage((Robot)lauchers.get(i), CONNEXION_SQUAD, EMPTY_ARGS);
      }
    }
  }

  boolean looseTeam() {
    Robot teamate = game.getRobot((int) brain[3].x);

    return teamate == null || distance(teamate) > messageRange;
  }

  // Drive ally harvester when food found
  void driveHarvester() {
    // look for burgers
    Burger zorg = (Burger)minDist(perceiveBurgers());
    if (zorg != null) {
      // if one is seen, inform harvester
      informAboutFood(game.getRobot((int) brain[3].x), zorg.pos);
    }
  }

  //
  // selectTarget
  // ============
  // > try to localize a target
  //
  void selectTarget() {
    // look for the closest ennemy robot
    Robot bob = (Robot)minDist(perceiveRobots(ennemy));
    if (bob != null) {
      // if one found, record the position and breed of the target
      brain[0].x = bob.pos.x;
      brain[0].y = bob.pos.y;
      brain[0].z = bob.breed;
      // locks the target
      brain[4].y = 1;
    } else
      // no target found
      brain[4].y = 0;
  }

  //
  // target
  // ======
  // > checks if a target has been locked
  //
  // output
  // ------
  // > true if target locket / false if not
  //
  boolean target() {
    return (brain[4].y == 1 || brain[4].y == 2);
  }

  //
  // goBackToBase
  // ============
  // > go back to the closest base
  //
  void goBackToBase() {
    sendMessage((int) brain[3].x, BACK_TO_BASE, EMPTY_ARGS);
    // look for closest base
    Base bob = (Base)minDist(myBases);
    if (bob != null) {
      // if there is one, compute its distance
      float dist = distance(bob);

      if (dist <= 2) {
        if(looseTeam())
          brain[4].z = NO_ROLE;

        // if next to the base
        if (energy < 500)
          // if energy low, ask for some energy
          askForEnergy(bob, 1500 - energy);
        // go back to "exploration" mode
        brain[4].x = 0;
        // make a half turn
        right(180);
      } else {
        // if not next to the base, head towards it... 
        heading = towards(bob) + random(-radians(20), radians(20));
        // ...and try to move forward
        tryToMoveForward();
      }
    }
  }

  //
  // tryToMoveForward
  // ================
  // > try to move forward after having checked that no obstacle is in front
  //
  void tryToMoveForward() {
    // if there is an obstacle ahead, rotate randomly
    if (!freeAhead(speed))
      right(random(360));

    // if there is no obstacle ahead, move forward at full speed
    if (freeAhead(speed))
      forward(speed);
  }

  //
  // handleMessages
  // ==============
  // > handle messages received
  // > identify the closest localized burger
  //
  void handleMessages() {
    Message msg;
    // for all messages
    for (int i=0; i<messages.size(); i++) {
      // get next message
      msg = messages.get(i);
      
      // Check message is from ally
      Robot transmitter = game.getRobot(msg.alice);
      if(transmitter != null && transmitter.colour != friend) continue;

      if(msg.type == SEARCH_LAUNCHER_NO_ROLE && brain[3].x == -1 && brain[4].z == NO_ROLE){
        brain[4].z = WAITING_ROLE;
        brain[3].x = msg.alice;
        sendMessage(msg.alice, FREE, EMPTY_ARGS);
      } else if (msg.type == CONNEXION_LAUNCHER || msg.type == CONNEXION_DEFENDER || msg.type == CONNEXION_SQUAD){
        if(brain[3].x == -1 && brain[4].z == NO_ROLE){
          brain[3].x = msg.alice;
          sendMessage(msg.alice, CONFIRM_CONNEXION, EMPTY_ARGS);
        }
      }
      else if (msg.type == CONFIRM_CONNEXION){
        if(brain[4].z == SQUAD_LEADER){
          if(brain[2].x == -1){
            brain[2].x = msg.alice;
            sendMessage(msg.alice, CONFIRM_CONNEXION, new float[]{SQUAD_SOLDIER});
          }
          else if(brain[2].y == -1){
            brain[2].y = msg.alice;
            sendMessage(msg.alice, CONFIRM_CONNEXION, new float[]{SQUAD_SOLDIER});
          }
          else if(brain[2].z == -1){
            brain[2].z = msg.alice;
            sendMessage(msg.alice, CONFIRM_CONNEXION, new float[]{SQUAD_SOLDIER});
          }
          else{
            sendMessage(msg.alice, ABORT_CONNEXION, EMPTY_ARGS);
        }
      }
        else{
        if(brain[3].x == msg.alice){
            brain[4].z = msg.args[0]; // Robot Type
          }
        }
      }
      else if (msg.type == ABORT_CONNEXION){
        if(brain[3].x == msg.alice){
          brain[4].z = NO_ROLE;
          brain[3].x = -1;
        }
      }
      else if (msg.type == UPDATE_DIRECTION){
        if((brain[4].z == HARVEST_ROLE || brain[4].z == SQUAD_SOLDIER ) && brain[3].x == msg.alice){
          brain[3].y = msg.args[0];
          brain[3].z = msg.args[1];
        }
      }
      else if ((brain[4].z == NO_ROLE || brain[4].z == WAITING_ROLE) && msg.type == PROMUTE_SQUAD_LEADER){ //PROMUTE TO SQUAD LEADER
        brain[4].z = SQUAD_LEADER;
      }
      else if(msg.type == INFORM_ABOUT_TARGET) {
        if(brain[4].z == DEFEND_ROLE && brain[3].x == msg.alice) {
          // Get target from base
          brain[0].x = msg.args[0];
          brain[0].y = msg.args[1];
          // locks the target
          brain[4].y = 2;
        }
      }
      /* UNUSED
      else if (msg.type == ATTACK_TARGET){
        if(brain[4].z == DEFEND_ROLE && brain[3].x == msg.alice){
          brain[0].x = msg.args[0];
          brain[0].y = msg.args[1];
          // locks the target
          brain[4].y = 1;
        }
      }*/
    }
    // clear the message queue
    flushMessages();
  }
}
