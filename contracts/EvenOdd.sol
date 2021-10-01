pragma solidity >=0.4.25 <0.6.0;

import "./SimpleCommit.sol";

contract EvenOdd {

    using SimpleCommit for SimpleCommit.CommitType;

    enum State{START, WAITING_PLAYER, READY_TO_DISCLOSE, OWNER_VALUE_DISCLOSED, PLAYER_VALUE_DISCLOSED, VALUES_DISCLOSED, END}
    enum Result  {OWNER_WON, PLAYER_WON, DRAW}

    SimpleCommit.CommitType ownerValue;
    SimpleCommit.CommitType guestValue;

    address payable owner;
    address payable guest;

    uint256 betValue;
    uint256 blockLimit;


    State state = State.START;

    bool ownerDisclosed = false;
    bool playerDisclosed = false;
    Result result = Result.DRAW;

    constructor (bytes32 _vD) public payable{
        ownerValue.commit(_vD);
        betValue = msg.value;
        blockLimit = block.number + 10;
        //????
        owner = msg.sender;
        state = State.WAITING_PLAYER;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Somento o dono pode chamar esta funcao!");
        _;}

    modifier onlyGuest {
        require(msg.sender == guest, "Somento o jogador pode chamar esta funcao!");
        _;}

    function joinGame(bytes32 _vJ) public payable {

        require(state == State.WAITING_PLAYER, "O jogo já possui um jogador");
        require(msg.value <= betValue, string(abi.encodePacked("Valor maior do que o da aposta: ", uint2str(msg.value), ". Limite: ", uint2str(betValue))));

        guestValue.commit(_vJ);
        guest = msg.sender;

        state = State.READY_TO_DISCLOSE;
    }

    function ownerReveal(bytes32 nonce1, byte _v1) public onlyOwner {
        require(state == State.READY_TO_DISCLOSE || (state == State.PLAYER_VALUE_DISCLOSED && !ownerDisclosed), "Seu valor não pode ser revelado");
        ownerValue.reveal(nonce1, _v1);
        ownerDisclosed = true;
        state = state == State.READY_TO_DISCLOSE ? State.OWNER_VALUE_DISCLOSED : State.VALUES_DISCLOSED;
    }


    function guestReveal(bytes32 nonce1, byte _v1) public onlyGuest {
        require(state == State.READY_TO_DISCLOSE || (state == State.OWNER_VALUE_DISCLOSED && !playerDisclosed), "Seu valor não pode ser revelado");
        guestValue.reveal(nonce1, _v1);
        playerDisclosed = true;
        state = state == State.READY_TO_DISCLOSE ? State.PLAYER_VALUE_DISCLOSED : State.VALUES_DISCLOSED;
    }

    function payOwner() internal returns (string memory) {
        result = Result.OWNER_WON;
        return "Dono foi o vencedor";
    }

    function payGuest() internal returns (string memory){
        result = Result.PLAYER_WON;
        return "Jogador Visitante foi o vencedor";
    }

    function repay() internal pure returns (string memory){
        return "Dinheiro devolvido";

    }

    function handleLimit() private returns (string memory){
        if (state == State.VALUES_DISCLOSED) {
            int8 bit = int8(ownerValue.getValue() ^ guestValue.getValue()) % 2 ** 1;
            if (bytes1(bit) == 0) {
                return payOwner();
            } else {
                return payGuest();
            }
        } else {
            if (state == State.PLAYER_VALUE_DISCLOSED)
                return payGuest();
            else if (state == State.OWNER_VALUE_DISCLOSED)
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

        if (block.number > blockLimit) {
            string memory message = handleLimit();
            state = State.END;
            return message;
        }

        require(state == State.VALUES_DISCLOSED, "O jogo não pode ser finalizado");
        state = State.END;

        int8 bit = int8(ownerValue.getValue() ^ guestValue.getValue()) % 2 ** 1;

        if (bytes1(bit) == 0)
            return payOwner();
        return payGuest();

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
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
