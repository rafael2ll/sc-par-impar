pragma solidity >=0.4.25 <0.6.0;

import "./SimpleCommit.sol";

contract parImpar {

 

using SimpleCommit for SimpleCommit.CommitType;

 


// Estados: aguardaJogador, revelaValores12, revelado, Fim....

enum State{START, WAITING_PLAYER, READY_TO_DISCLOSE, OWNER_VALUE_DISCLOSED, PLAYER_VALUE_DISCLOSED, VALUES_DISCLOSED, END}
enum Result  {OWNER_WON, PLAYER_WON, DRAW}

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
Result result = Result.DRAW;

constructor (bytes32 _vD) public payable{
    valorDono.commit(_vD);
    valorAposta = msg.value;
    limiteBloco = block.number + 10; //????
    dono =msg.sender;
    state = State.WAITING_PLAYER;
}

 

modifier onlyOwner {require (msg.sender == dono,"Somento o dono pode chamar esta funcao!");_;}
modifier onlyPlayer {require (msg.sender == jogador,"Somento o jogador pode chamar esta funcao!");_;}

function entraJogo(bytes32 _vJ) public payable{
    
    require(state == State.WAITING_PLAYER, "O jogo já possui um jogador");
    require (msg.value <= valorAposta, string(abi.encodePacked("Valor maior do que o da aposta: ", uint2str(msg.value), ". Limite: ", uint2str(valorAposta))));
    
    valorJogador.commit(_vJ);
    jogador = msg.sender;
    
    state = State.READY_TO_DISCLOSE;
}

 

function ownerReveal(bytes32 nonce1, byte _v1) public onlyOwner {
  require(state == State.READY_TO_DISCLOSE || (state == State.PLAYER_VALUE_DISCLOSED && !ownerDisclosed), "Seu valor não pode ser revelado");
  valorDono.reveal(nonce1,_v1);
  ownerDisclosed = true;
  state = state == State.READY_TO_DISCLOSE ? State.OWNER_VALUE_DISCLOSED : State.VALUES_DISCLOSED;
}

 

function playerReveal(bytes32 nonce1, byte _v1) public onlyPlayer {
  require(state == State.READY_TO_DISCLOSE || (state == State.OWNER_VALUE_DISCLOSED && !playerDisclosed), "Seu valor não pode ser revelado");
  valorJogador.reveal(nonce1,_v1);
  playerDisclosed = true;
  state = state == State.READY_TO_DISCLOSE ? State.PLAYER_VALUE_DISCLOSED : State.VALUES_DISCLOSED;
}

 
 
 function payOwner() internal returns (string memory) {
     result = Result.OWNER_WON;
     return "Dono foi o vencedor";
 }
 
 function payPlayer() internal returns (string memory){
     result = Result.PLAYER_WON;
     return "Jogador Visitante foi o vencedor";
 }
 
 function repay() internal pure returns (string memory){
     return "Dinheiro devolvido";
     
 }
 
 
function handleLimit() private returns (string memory){
    if(state == State.VALUES_DISCLOSED){
        int8 bit = int8(valorDono.getValue() ^ valorJogador.getValue()) % 2 ** 1;
        if(bytes1(bit) == 0){
            return payOwner();
        }else{
            return payPlayer();
        }
    }else{
        if(state == State.PLAYER_VALUE_DISCLOSED)
            return payPlayer();
        else if(state == State.OWNER_VALUE_DISCLOSED)
            return payOwner();
        else
            return repay();
    }    
}


function whoWon() public view returns (string memory){
    require(state == State.END, "O jogo ainda não foi finalizado");
    return result == Result.OWNER_WON ? "O dono do contrato foi o vencedor!" : result == Result.PLAYER_WON ? "O jogador visitante foi o vencedor!" : "Empate!";
}

function payWinner() public returns (string memory){
   require(state != State.END, "O jogo foi finalizado");
   
   if(block.number > limiteBloco){
        string memory message = handleLimit();
        state = State.END;
        return message;
   }
   
    require(state == State.VALUES_DISCLOSED, "O jogo não pode ser finalizado");
    state = State.END;

    int8 bit = int8(valorDono.getValue() ^ valorJogador.getValue()) % 2 ** 1;
    
    if(bytes1(bit) == 0) 
        return payOwner();
    return payPlayer();
    
}

function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}