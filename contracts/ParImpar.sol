pragma solidity >=0.4.25 <0.6.0;

import "./SimpleCommit.sol";

contract parImpar {

 

using SimpleCommit for SimpleCommit.CommitType;

 


// Estados: aguardaJogador, revelaValores12, revelado, Fim....

enum State{START, WAITING_PLAYER, READY_TO_DISCLOSE, OWNER_VALUE_DISCLOSED, PLAYER_VALUE_DISCLOSED, VALUES_DISCLOSED, END}

SimpleCommit.CommitType valorDono;
SimpleCommit.CommitType valorJogador;

 

address payable dono;
address payable jogador;

 

uint256 valorAposta;
uint256 limiteBloco;

 
State state = State.START;

// flags!!!!!

bool ownerDisclosed = false;
bool playerDisclosed = false;

function setValorAposta() internal{
    valorAposta = msg.value;
}


constructor (bytes32 _vD) public {
    valorDono.commit(_vD);
    setValorAposta();
    limiteBloco = block.number + 10; //????
    dono =msg.sender;
    state = State.WAITING_PLAYER;
}

 

function requireLessValue() internal{
    require ( msg.value >= valorAposta,"Valor maior do que o da aposta");
}


modifier onlyOwner {require (msg.sender == dono,"Somento o dono pode chamar esta funcao!");_;}
modifier onlyPlayer {require (msg.sender == jogador,"Somento o jogador pode chamar esta funcao!");_;}
modifier capValue {requireLessValue();_;}

function entraJogo(bytes32 _vJ) public capValue {
    require(state == State.WAITING_PLAYER, "O jogo já possui um jogador");
    
    valorJogador.commit(_vJ);
    jogador = msg.sender;
    
    state = State.READY_TO_DISCLOSE;
}

 

function ownerReveal(bytes32 nonce1, byte _v1) public onlyOwner {
  require(state == State.READY_TO_DISCLOSE || (state == State.PLAYER_VALUE_DISCLOSED && !ownerDisclosed), "Seu valor não pode ser revelado");
  
  valorDono.reveal(nonce1,_v1);
  //ok = sc1.isCorrect();
  state = state == State.READY_TO_DISCLOSE ? State.OWNER_VALUE_DISCLOSED : State.VALUES_DISCLOSED;
}

 

function playerReveal(bytes32 nonce1, byte _v1) public onlyPlayer {
  require(state == State.READY_TO_DISCLOSE || (state == State.OWNER_VALUE_DISCLOSED && !playerDisclosed), "Seu valor não pode ser revelado");
  
  valorJogador.reveal(nonce1,_v1);
  //ok = sc1.isCorrect();
  state = state == State.READY_TO_DISCLOSE ? State.PLAYER_VALUE_DISCLOSED : State.VALUES_DISCLOSED;
}

 
 
 function payOwner() internal pure{
     require(false, "Dono foi o vencedor");
 }
 
 function payPlayer() internal pure{
     require(false, "Jogador foi o vencedor");
 }
 
 function repay() internal pure{
     require(false, "Dinheiro devolvido");
     
 }
 
function handleLimit() private view{
    if(state == State.VALUES_DISCLOSED){
        int8 bit = int8(valorDono.value ^ valorJogador.value) % 2 ** 1;
        if(bytes1(bit) == 0){
            payOwner();
        }else{
            payPlayer();
        }
    }else{
        if(state == State.PLAYER_VALUE_DISCLOSED)
            payPlayer();
        else if(state == State.OWNER_VALUE_DISCLOSED)
            payOwner();
        else
            repay();
    }    
}

function payWinner() public {
   if(block.number > limiteBloco)
        handleLimit();
    else if(state == State.VALUES_DISCLOSED){
        int8 bit = int8(valorDono.value ^ valorJogador.value) % 2 ** 1;
        if(bytes1(bit) == 0){
            payOwner();
        }else{
            payPlayer();
        }
    }else{
        require(false, "O jogo não pode ser finalizado");
    }
    state = State.END;
    
}

// function pagaVencedor() public {
// Quem é o vencedor???
// *** verificar bloco limite ***
// Se bloco passou o limite e ninguem revelou ???
// Se o jogador revelou corretamente e o dono nao: jagador ganha e é pagaVencedor
// Se dono......

 

// Se ambos revelaram junte o valor com valorDono.getValue() e valorJoador.getValue() e determine o vencedor
  
//}
}