pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./ERC721BasicToken.sol";

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721, ERC721BasicToken {
  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) public ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) public ownedTokensIndex;

  // Mapping from token ID to index of Harlic
  mapping(uint256 => uint256) public tokenHarlic;

  // Mapping from token ID to indices of Taxlog
  mapping(uint256 => uint256) public tokenTaxlog;

  // Array with all token ids, used for enumeration
  uint256[] public allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) public allTokensIndex;

  // Optional mapping for token URIs
  mapping(uint256 => string) public tokenURIs;

  /** STRUCTS **/
  struct Harlic {
     uint256 tokenID;
     uint256 turnoverRate; //per year
     uint256 harlicValue; //ether
     uint256 publicEquity;
     address privateRentier;
  }

  struct Taxlog {
     uint256 tokenID;
     uint256 paidTaxes;
     uint256[] dateSeries; //dates on which value adjusted since last tax payment
     uint256[] harlicValueSeries; //values in each period

  }

  Harlic[] public harlics;
  Taxlog[] public taxlogs;

  /**
   * @dev Constructor function
   */
  constructor() public {
    name_ = "HarbergerLicense";
    symbol_ = "HARB";
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() public view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() public view returns (string) {
    return symbol_;
  }

  /**
   * @dev Returns an URI for a given token ID
   * @dev Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256)
  {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * @dev Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * @dev Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * @dev Reverts if the given token ID already exists
   * @param _to address the beneficiary that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _owner owner of the token to burn
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

  function publicMint(      //put into the internal _mint after testing finished
    address _to,
    uint256 _tokenId,
    uint256 _turnoverRate,
    uint256 _harlicValue,
    uint256 _publicEquity,
    address _privateRentier) public returns (bool) {

    require(_turnoverRate > 0 && _turnoverRate < 100); // require percentage
    require(_publicEquity >= 0 && _publicEquity <= 100); // require percentage

    Harlic memory _harlic = Harlic({
        tokenID: _tokenId,
        turnoverRate: _turnoverRate,
        harlicValue: _harlicValue,
        publicEquity: _publicEquity,
        privateRentier: _privateRentier
    });
    harlics.push(_harlic) - 1; //create harlic struct for token

    Taxlog memory _taxlog = Taxlog({
        tokenID: _tokenId,
        paidTaxes: 0,
        dateSeries: new uint256[](0),
        harlicValueSeries: new uint256[](0)
    });
    taxlogs.push(_taxlog) - 1; //create taxlog struct for token

    taxlogs[taxlogs.length - 1].dateSeries.push(now);
    taxlogs[taxlogs.length - 1].harlicValueSeries.push(_harlicValue);

    tokenTaxlog[_tokenId] = taxlogs.length - 1; //make record of associated taxlog
    tokenHarlic[_tokenId] = harlics.length - 1; //make record of associated harlic

    _mint(_to, _tokenId); //create token

  }

  function selfAssess (uint256 _tokenId, uint256 _value)
    public onlyOwnerOf(_tokenId)
    returns (bool) {

    /*prevent out-of-chronological-order assessments*/
    require(taxlogs[tokenIndex].dateSeries[taxlogs[tokenIndex].dateSeries.length-1] < now);

    /*update self-assessed value*/
    uint256 tokenIndex = allTokensIndex[_tokenId];
    taxlogs[tokenIndex].harlicValueSeries.push(_value);
    taxlogs[tokenIndex].dateSeries.push(now);

  }

  function calculateTax(uint256 _tokenId) public returns (uint256) {

    /*tax calculation, working*/
    require(exists(_tokenId) == true);
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 allTimeTax;

    //uint256 taxR;
    //uint256 periodL;
    //uint256 periodV;

    for (uint i = 0; i <= taxlogs[tokenIndex].harlicValueSeries.length-2; i++) {
        uint256 periodValuation = SafeMath.mul(taxlogs[tokenIndex].harlicValueSeries[i], 1000000000000000000);
        uint256 periodLength =
            SafeMath.sub(taxlogs[tokenIndex].dateSeries[i+1], taxlogs[tokenIndex].dateSeries[i]); // in seconds
        uint256 taxRate = SafeMath.div(SafeMath.div(SafeMath.mul(harlics[tokenIndex].turnoverRate, periodValuation),
            100),
            31536000); //divide rate into seconds in a year and multiply by valuation for per second tax
        allTimeTax += SafeMath.mul(taxRate, periodLength);

        //taxR += taxRate;
        //periodL += periodLength;
        //periodV += periodValuation;

    }
    return (allTimeTax);
  }

  function payTax (uint256 _tokenId)
    public payable returns (uint256) {

        uint256 allTimeTax = calculateTax(_tokenId);
        uint256 index = allTokensIndex[_tokenId];
        uint256 paidTaxes = taxlogs[index].paidTaxes;
        uint256 owedTaxes = SafeMath.sub(allTimeTax, paidTaxes); //doing anything with this var?

        taxlogs[index].paidTaxes += msg.value;


    }

  function acquireToken () public payable returns (bool) {

  }

  /**CUSTOM GETTERS**/

  function getTaxesByIndex(uint256 _index) public view returns (uint256[], uint256[]) {
    return (taxlogs[_index].dateSeries, taxlogs[_index].harlicValueSeries);
    //now, build calculator that calculates unpaid tax: (SUM OF (time/year)*value in period) - paid Taxes

  }

}
