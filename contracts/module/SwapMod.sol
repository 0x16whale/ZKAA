//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {IUniswapV3Factory} from "../../interfaces/uniswapv3/IUniswapFactory.sol";
import {ISwapRouter02, IV2SwapRouter, IV3SwapRouter} from "../../interfaces/uniswapv3/ISwapRouter02.sol";
import {IVizingSwap} from "../../interfaces/IVizingSwap.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SwapMod is Ownable, ReentrancyGuard, IVizingSwap{
    using SafeERC20 for IERC20;
    
    bool public lockState;
    address[] private routers;

    receive()external payable{}

    constructor(address _router)Ownable(msg.sender){
        routers.push(_router);
    }

    modifier lock(){
        require(lockState == false,"Already lock");
        _;
    }

    function setLock(bool _lockState)external onlyOwner{
        lockState = _lockState;
    }

    function addRouter(address _newRouter)external onlyOwner{
        routers.push(_newRouter);
    }

    function removeRouter(uint256 _indexOldRouter)external onlyOwner{
        delete routers[_indexOldRouter];
    }

    function v3ExactInputSingle(v3ExactInputParams calldata params)external payable nonReentrant lock{
        address router=routers[params.index];
        uint256 tokenInAmount;
        if(params.tokenIn == address(0)){
            tokenInAmount = msg.value;
            require(msg.value >= params.amountIn,"Send eth insufficient");
        }else{
            tokenInAmount = params.amountIn;
            IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), tokenInAmount);
            IERC20(params.tokenIn).safeIncreaseAllowance(router, tokenInAmount);
        }
        IV3SwapRouter.ExactInputSingleParams memory v3Params=IV3SwapRouter.ExactInputSingleParams({
            tokenIn: params.tokenIn,
            tokenOut: params.tokenOut,
            fee: params.fee,
            recipient: params.recipient,
            amountIn: tokenInAmount,
            amountOutMinimum: params.amountOutMinimum,
            sqrtPriceLimitX96: params.sqrtPriceLimitX96
        });
        uint256 amountOut=ISwapRouter02(router).exactInputSingle{value: msg.value}(v3Params);
        emit VizingSwapEvent(msg.sender, params.tokenIn, params.tokenOut, params.recipient, tokenInAmount, amountOut);
    }

    function v2SwapExactTokensForTokens(V2SwapExactTokensForTokensParams calldata params)external payable nonReentrant lock{
        address router=routers[params.index];
        address tokenIn=params.path[0];
        uint256 tokenInAmount;
        if(tokenIn == address(0)){
            tokenInAmount = msg.value;
            require(msg.value >= params.amountIn,"Send eth insufficient");
        }else{
            tokenInAmount = params.amountIn;
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), tokenInAmount);
            IERC20(tokenIn).safeIncreaseAllowance(router, tokenInAmount);
        }

        uint256 amountOut=ISwapRouter02(router).swapExactTokensForTokens{value: msg.value}(
            tokenInAmount,
            params.amountOutMin,
            params.path,
            params.recipient
        );
        emit VizingSwapEvent(msg.sender, tokenIn, params.path[params.path.length-1], params.recipient, tokenInAmount, amountOut);
    }

    function _getTokenBalance(address _token,address _user)private view returns(uint256 _balance){
        _balance = IERC20(_token).balanceOf(_user);
    }

    function getTokenBalance(address token,address user)external view returns(uint256){
        return _getTokenBalance(token,user);
    }

    function routerLength()external view returns(uint256){
        return routers.length;
    }

    function indexRouter(uint256 index)public view returns(address){
        return routers[index];
    }


}