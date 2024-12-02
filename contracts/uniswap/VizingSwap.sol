//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.23;

import {IUniswapV3Factory} from "../../interfaces/uniswapv3/IUniswapFactory.sol";
import {ISwapRouter02, IV2SwapRouter, IV3SwapRouter} from "../../interfaces/uniswapv3/ISwapRouter02.sol";
import {IVizingSwap} from "../../interfaces/IVizingSwap.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IWETH9} from "../../interfaces/IWETH9.sol";

contract VizingSwap is Ownable, ReentrancyGuard, IVizingSwap{
    using SafeERC20 for IERC20;

    address private weth;
    address[] private routers;

    receive()external payable{}

    constructor(address _router,address _weth)Ownable(msg.sender){
        weth=_weth;
        routers.push(_router);
    }

    function addRouter(address _newRouter)external onlyOwner{
        routers.push(_newRouter);
    }

    function removeRouter(uint256 _indexOldRouter)external onlyOwner{
        delete routers[_indexOldRouter];
    }

    function v3ExactInputSingle(v3ExactInputParams calldata params)external payable nonReentrant{
        address router=routers[params.index];
        address _tokenIn=params.tokenIn;
        address _tokenOut=params.tokenOut;
        address receiver=params.recipient;
        if(params.tokenIn == address(0)){
            require(msg.value >= params.amountIn,"Send eth insufficient");
            _tokenIn=weth;
            IWETH9(weth).deposit{value: msg.value}();
        }else if(params.tokenOut == address(0)){
            _tokenOut=weth;
            receiver=address(this);
            IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);
        }else{
            IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);
        }
        IERC20(_tokenIn).approve(router, params.amountIn);

        IV3SwapRouter.ExactInputSingleParams memory v3Params=IV3SwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            fee: params.fee,
            recipient: receiver,
            amountIn: params.amountIn,
            amountOutMinimum: params.amountOutMinimum,
            sqrtPriceLimitX96: params.sqrtPriceLimitX96
        });
        uint256 amountOut=ISwapRouter02(router).exactInputSingle(v3Params);
        if(_tokenOut == weth){
            uint256 wethBalance=IERC20(weth).balanceOf(address(this));
            uint256 withdrawWETHAmount=wethBalance>=amountOut?amountOut:wethBalance;
            IWETH9(weth).withdraw(withdrawWETHAmount);
            (bool suc,)=params.recipient.call{value: withdrawWETHAmount}("");
            require(suc, "Withdraw eth fail");
        }
        emit VizingSwapEvent(msg.sender, params.tokenIn, params.tokenOut, params.recipient, params.amountIn, amountOut);
    }

    function v2SwapExactTokensForTokens(V2SwapExactTokensForTokensParams calldata params)external payable nonReentrant{
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