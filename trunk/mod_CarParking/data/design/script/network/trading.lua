
TRADING = {}




--                      TRADING HOWTO
--  The function are meant to be used in the following way:
--  - ask for an update: GetCityTokens(), GetCityOffers(), GetCityContracts()
--  - the call are asynchronous; some day, someone will get a result for these,
--    which will be written in static structure (TRADING.CityTokenPotential, etc.)
--  - the table TRADING.NotificationOut should be checked regularly by the caller
--    since a lot of answers will arrive here.
--



-- Status to use:
--
-- *** traOfferAnswerState
--    netapi.traAnswerState_UNDEFINED
--    netapi.traAnswerState_ACCEPTED
--    netapi.traAnswerState_REJECTED
--    netapi.traAnswerState_CANCELLED
--    netapi.traAnswerState_MAXVALUE
--
-- *** traContractState
--  netapi.traContractState_UNDEFINED     
--  netapi.traContractState_OFFER_CREATED 
--  netapi.traContractState_OFFER_VALID   
--  netapi.traContractState_OFFER_INVALID 
--  netapi.traContractState_OFFER_REJECTED
--  netapi.traContractState_OFFER_CANCELLED
--  netapi.traContractState_OFFER_DEFERRED
--
--  netapi.traContractState_ACTIVE        
--  netapi.traContractState_CANCELLED     
--  netapi.traContractState_FINISHED      
--  netapi.traContractState_ALERTED       
--  netapi.traContractState_NEGOTIATING   
--  netapi.traContractState_DEFERRED      
--  netapi.traContractState_MAXVALUE
--
-- *** traContractAnswerState
--    netapi.traContractAnswerState_UNDEFINED
--    netapi.traContractAnswerState_CANCELLED
--    netapi.traContractAnswerState_MAXVALUE
--
--
-- *** traCycleState
--    netapi.traCycle_UNDEFINED
--    netapi.traCycle_PAST
--    netapi.traCycle_CURRENT
--    netapi.traCycle_FUTURE
--    netapi.traCycle_MAX
--
--
-- *** traAlertState
--    netapi.traAlertState_UNDEFINED
--    netapi.traAlertState_OFFER_VALID
--    netapi.traAlertState_OFFER_INVALID
--    netapi.traAlertState_OFFER_ACCEPTED
--    netapi.traAlertState_OFFER_REJECTED
--    netapi.traAlertState_CONTRACT_ALERTED
--    netapi.traAlertState_CONTRACT_CANCELLED
--    netapi.traAlertState_CONTRACT_FINISHED
--    netapi.traAlertState_CONTRACT_RENEGOCIATING
--    netapi.traAlertState_OFFER_CANCELLED
--    netapi.traAlertState_NEW_SERVER_CYCLE
--    netapi.traAlertState_NEW_ALLOCATION


--    netapi.traAlertState_BAD_CONTRACT_STATE
--    netapi.traAlertState_OFFER_NOT_BOUND_TO_CONTRACT
--    netapi.traAlertState_BAD_OFFER_STATE
--    netapi.traAlertState_INCONSISTENT_EXCHANGELIST
--    netapi.traAlertState_CITY_NEEDS_MORE_TOKEN
--    netapi.traAlertState_OFFER_NOT_MINE
--    netapi.traAlertState_OFFER_NOT_FOUND
--    netapi.traAlertState_CONTRACT_NOT_FOUND
--    netapi.traAlertState_SERVCYCLE_NOT_FOUND
--    netapi.traAlertState_OFFER_NOT_DESTINED_TO_ME
--    netapi.traAlertState_CONTRACT_NOT_MINE
--    netapi.traAlertState_CITY_NEEDS_MORE_TRANSPORT
--    netapi.traAlertState_MAXVALUE
--
--
-- *** traErrorCode
--    netapi.traErrorCode_UNDEFINED
--    netapi.traErrorCode_FAILED
--    netapi.traErrorCode_SUCCESS
--    netapi.traErrorCode_COUNT
--
-- *** traTransportType   
--    netapi.traTransport_UNDEFINED 
--    netapi.traTransport_FREIGHT     
--    netapi.traTransport_PASSENGER 
--    netapi.traTransport_IMMATERIAL  
--    netapi.traTransport_COUNT
-- 
-- *** bpAlertState
--  bpAlertState_UNDEFINED
--  bpAlertState_BLUEPRINT_ACTIVATED
--  bpAlertState_BLUEPRINT_NEW_OFFER
--  bpAlertState_BLUEPRINT_OFFER_ACCEPTED
--  bpAlertState_BLUEPRINT_OFFER_REJECTED
--  bpAlertState_BLUEPRINT_OFFER_CANCELLED
--  bpAlertState_MEGA_NEW_OFFER
--  bpAlertState_MEGA_OFFER_ACCEPTED
--  bpAlertState_MEGA_OFFER_REJECTED
--  bpAlertState_MEGA_OFFER_CANCELLED


-- PUBLICLY AVAILABLE --
TRADING.TokenDesc = {}

TRADING.CityTokens = {}
TRADING.CityTokenContracts = {}
TRADING.UnboundContracts = {}
TRADING.GpTokenAllocs = {}

TRADING.GpTokenAllocsByName = {}

TRADING.GpPlayer = {}

TRADING.NotificationOut = {}
TRADING.NotificationBpOut = {}
TRADING.TokenSearchResult = {}
TRADING.TokenPriceHistory = {}

TRADING.BpDesc = {}
TRADING.PlayerBp = {}
TRADING.CityGp = {}

-- INTERNAL PURPOSE --
TRADING.iCashIndex = 1
TRADING.iFirstToken = 1
TRADING.NbTokenTypes = 15
TRADING.CityContractsReq = {}
TRADING.NbBpTypes = 0

TRADING.g_Offer = nil
TRADING.g_Exc = nil
TRADING.g_AllocList = nil
TRADING.g_Alloc = nil

TRADING.m_aCallbacks = {}
TRADING.m_aCallbacks["CityTokens"] = {}


TRADING.MultiDesc = {}
TRADING.MultiAlias = {}
TRADING.CityMulti = {}

TRADING.Multinationals = false 

function GetFormattedDateYMD( _Year, _Month, _Day)
    if (_Month < 10) then 
        return tostring(_Day) .. "/0" .. tostring(_Month) .. "/" .. tostring(_Year)
    else    
        return tostring(_Day) .. "/" .. tostring(_Month) .. "/" .. tostring(_Year)
    end    
end

function GetDateTabFromDBDate(_strDate)
	
	local aStrDate = InterfaceUtilities:StringSplit(_strDate, "-")
	
	local aDate = {}
	
	if #aStrDate >= 3 then
		
		aDate.year = aStrDate[1]
		aDate.month = aStrDate[2]
		
		aStrDate = InterfaceUtilities:StringSplit(aStrDate[3], " ")
	
		aDate.day = aStrDate[1]
		
		return aDate
	end
	
	LOG_ERROR("Trading:GetDateTabFromDBDate: Cannot parse DB date [" .. _strDate ..  "] !")
	
	return nil
	
end

function TRADING:InitTrading()
	if cnx then
	    cnx:Trading():InitClient()
	    cnx:Trading():InitBlueprints()
		if (TRADING.Multinationals) then 
			--LOG_INFO(nil)
			cnx:SimNet():InitMulti()
		else
			TRADING:CheckInitMulti()
		end		
		
  end
end

function TRADING:GetCityTokens(_CityId)
	if cnx and (_CityId~=-1) and (_CityId~=0) then
		if (TradeWaitMgr:DidRecently(5,tradeAction.TokenStatus, _CityId)==false) then 
			if (TradeWaitMgr:Doing(tradeAction.TokenStatus, _CityId)==false) then 
				cnx:Trading():GetCityTokens(_CityId)
				return true
			end	
		
		end
	end
	
	return false
end

-- for the current planet, of course
-- _iHours between 6 and 24 * 7
function TRADING:GetTokenPriceHistory(_iTokenType, _iHours)
	if cnx and (_iTokenType~= 0) then 
		if  (TradeWaitMgr:DidRecently(300,tradeAction.PriceHistory,_iTokenType)==false) then
			if (TradeWaitMgr:Doing(tradeAction.PriceHistory,_iTokenType)==false) then 
				cnx:Trading():GetTokenPriceHistory(_iTokenType, _iHours)
			end	
		else
			InterfaceUtilities:LOG_CUSTOM1(" Token price history for ".._iTokenType.." recieved recently, discarding request")
		end
	end
end

-- _Tokens is an array, V k > 0, V i € [iFirstToken, NbTokenTypes]
--  _Tokens[i] = k <=> the city produces k tokens (type i)
--  _Tokens[i] = k <=> the city needs k tokens (type i)
function TRADING:SetCityProd(_CityId, _Tokens, _iRoad, _iSea, _iRail, _iAir)
	
	local vTokens = netapi.IntVector()
	for i=0,TRADING.NbTokenTypes
    do
        vTokens:push_back(0)
    end
    
    for k, v in pairs( _Tokens)
    do
    	vTokens[k] = v
    end
	
	if cnx then
		cnx:Trading():SetCityProd(_CityId, vTokens, _iRoad, _iSea, _iRail, _iAir)
	end
end

function TRADING:GetCityContracts(_CityId)
	
	if cnx then
	
		if (TradeWaitMgr:DidRecently(5,tradeAction.ListContracts,_CityId)==false) then
			
			if (TradeWaitMgr:Doing(tradeAction.ListContracts,_CityId) == false) then 
				local iReq = cnx:Trading():GetCityContracts(_CityId)
				TRADING.CityContractsReq[iReq] = _CityId
				return true
			end
		end
	end	
	
	return false
end

function TRADING:GetUnboundContracts( _TokenId)
	
	_TokenId = _TokenId or 0
	
	if cnx and (_TokenId~= 0) then
		--if (TradeWaitMgr:DidRecently(20,tradeAction.GetMarket,_TokenId)==false) then
			if (TradeWaitMgr:Doing(tradeAction.GetMarket,_TokenId) == false) then 
				cnx:Trading():GetUnboundContracts( _TokenId)
			end
		--end
		
	end
end

-- Amount > 0 <=> _FromId wants to sell these token
-- Amount < 0 <=> _FromId wants to buy these token
-- _GlobalPrice must be positive
function TRADING:SendNewUnboundOffer( _FromId, _Type, _Amount, _GlobalPrice)
    
    local Exchange = {}    
    Exchange[ _Type] = _Amount
    if _Amount > 0 then
        Exchange[ TRADING.iCashIndex] = 0 - _GlobalPrice
    else
        Exchange[ TRADING.iCashIndex] = _GlobalPrice
    end
    TRADING:InternalSendOffer( _FromId, 0, Exchange, '', 0)
end

-- _Exchange is an integer table - it must have *nb_tokens + 1* elements
-- V i € [1, 15], V k > 0, _Exchange[i] = k means the city proposes to export k tokens
-- V i € [1, 15], V k > 0, _Exchange[i] = -k means the city proposes to import k tokens
function TRADING:SendNewOffer(_FromId, _ToId, _Exchange, _EndDate)
    TRADING:InternalSendOffer(_FromId, _ToId, _Exchange, _EndDate, 0)
end

function TRADING:SendCounterOffer(_FromId, _ToId, _Exchange, _EndDate, _OriginalOfferId)
    TRADING:InternalSendOffer(_FromId, _ToId, _Exchange, _EndDate, _OriginalOfferId)
end

function TRADING:RenegotiateContract(_FromId, _ToId, _Exchange, _EndDate, _ContractId)
    TRADING:InternalSendOffer(_FromId, _ToId, _Exchange, _EndDate, _ContractId)
end

function TRADING:CounterOfferOnRenegotiateContract(_FromId, _ToId, _Exchange, _EndDate, _OfferId, _ContractId)
    -- LOG_ERROR( "Deprecated API: TRADING:CounterOfferOnRenegotiateContract")
end



function TRADING:AcceptOffer(_OfferId, _CityId)
	local CityId = _CityId or 0
	if cnx then
	
		-- local CityId = 
		
		if (TRADING:IsUnboundContractOmnicorp(_OfferId)) then 
			if (TradeWaitMgr:Doing(tradeAction.AcceptOmnicorpOffer, 0) == false) then 
				cnx:Trading():AcceptOffer(tonumber(_OfferId), CityId)
			end	
		else
			if (TradeWaitMgr:Doing(tradeAction.AcceptOffer,_OfferId) == false) then 
				cnx:Trading():AcceptOffer(tonumber(_OfferId), CityId)
			end	
		end	
	end
end

function TRADING:RejectOffer(_OfferId)
	if cnx then
    cnx:Trading():RejectOffer(tonumber(_OfferId))
  end
end

function TRADING:CancelOffer(_OfferId)
	if cnx then
		cnx:Trading():CancelOffer(tonumber(_OfferId))
	end
end

function TRADING:CancelContract(_ContractId)
	if cnx then
		InterfaceUtilities:LOG_CUSTOM1("Cancelling contract ".._ContractId)
		if (TradeWaitMgr:Doing(tradeAction.CancelContract,_ContractId) == false) then 
			cnx:Trading():CancelContract(tonumber(_ContractId))
			return true
		end	
	end
	
	return false 
	
end

-- _Token List is a table where: V TokenId € TokenDesc.keys(), _TokenList[TokenId] = WantedQuantity
-- _PlayerId and _CityId (if != 0) may refine the search to a specific player or city.
function TRADING:TokenSearch(_TokenList, _PlayerId, _CityId)

    local WantedTokens = netapi.IntVector()

    for i=0,TRADING.NbTokenTypes
    do
        WantedTokens:push_back(0)
    end

    for k,v in pairs(_TokenList)
    do
        if TRADING.TokenDesc[k] == nil then
            LOG_ERROR("Invalid token ID: " .. k)
            return
        end
        WantedTokens[k] = v
        -- LOG_ERROR("Need "..v.." of "..TRADING.TokenDesc[k])
    end

    TRADING.TokenSearchResult = {}
    
    if cnx then
	    cnx:Trading():TokenSearch( WantedTokens, _PlayerId, _CityId)
	end

end


-- not to be used outside this file
-- Hands off, Mr Hockley!
function TRADING:InternalSendOffer(_FromId, _ToId, _Exchange, _EndDate, _ContractId)


    if( TRADING.g_Offer == nil)
    then
        TRADING.g_Offer = netapi.traTokenContract()
    end

    if( TRADING.g_Exc == nil)
    then
        TRADING.g_Exc = netapi.IntVector()
    end

    TRADING.g_Offer.m_iSourceCityId = _FromId
    TRADING.g_Offer.m_iDestCityId = _ToId
    TRADING.g_Offer.m_iContractId = _ContractId
    TRADING.g_Offer.m_EndDate = _EndDate
    
    TRADING.g_Offer.m_Tokens:clear()
    for i=0,TRADING.NbTokenTypes
    do
        TRADING.g_Offer.m_Tokens:push_back(0)
    end
    
    for k,v in pairs(_Exchange)
    do
    		LOG_INFO("k:" .. tostring(k) .. "|v:" .. tostring(v))
        TRADING.g_Offer.m_Tokens[k] = v
    end
    
--    LOG_INFO("(Before) Offer = " .. tostring(TRADING.g_Offer))
--    LOG_INFO("(Before) ExchangeList = " .. tostring(TRADING.g_Offer.m_ExchangeList))
--    LOG_INFO("(Before) ExchangeList:size() = " .. tostring(TRADING.g_Offer.m_ExchangeList:size()))
--    for i = 0, TRADING.g_Offer.m_ExchangeList:size() - 1
--    do
--        LOG_INFO("(Before) ExchangeList[] = " .. tostring(TRADING.g_Offer.m_ExchangeList[i]))
--    end

		if cnx then
	    cnx:Trading():SendOffer(TRADING.g_Offer)
	  end

--    LOG_INFO("--> Returned from SendOffer()")
--    LOG_INFO("(After) Offer = " .. tostring(TRADING.g_Offer))
--    LOG_INFO("(After) ExchangeList = " .. tostring(TRADING.g_Offer.m_ExchangeList))
--    LOG_INFO("(After) ExchangeList:size() = " .. tostring(TRADING.g_Offer.m_ExchangeList:size()))
--
--    for i = 0, TRADING.g_Offer.m_ExchangeList:size() - 1
--    do
--        LOG_INFO("ExchangeList[] = " .. tostring(TRADING.g_Offer.m_ExchangeList[i]))
--        LOG_INFO("ExchangeList[] = " .. tostring(TRADING.g_Offer.m_ExchangeList[i].m_iSourceCityId))
--    end

end

g_KillOmniCorpSell = {}
--g_KillOmniCorpSell["worker1"] = true
--g_KillOmniCorpSell["worker2"] = true
--g_KillOmniCorpSell["worker3"] = true
--g_KillOmniCorpSell["worker4"] = true

function TRADING:CheckCanSellToOmnicorp(_TokenName)

    if (g_KillOmniCorpSell[_TokenName] == true) then 
        return false
    end

    return true

end

function TRADING:CheckInitTrading()

		if cnx == nil then
			return
		end

    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyInitClient)
    if nil ~= msg then

        TRADING.iFirstToken = 1
        TRADING.NbTokenTypes = 0
        
        LOG_INFO( "CheckInitTrading found a message, size = " .. msg.m_TokenList:size())


        for index = 0, msg.m_TokenList:size()-1
        do            
            TRADING.NbTokenTypes = TRADING.NbTokenTypes + 1
            TRADING.TokenDesc[ msg.m_TokenList[index].m_iId] = msg.m_TokenList[index].m_strAlias
            
            TradingLogic.OmniCorpBuyRate[msg.m_TokenList[index].m_strAlias] = msg.m_TokenList[index].m_ImportPrice / 100
            
            if (TRADING:CheckCanSellToOmnicorp(msg.m_TokenList[index].m_strAlias)) then 
                TradingLogic.OmniCorpSellRate[msg.m_TokenList[index].m_strAlias] = msg.m_TokenList[index].m_ExportPrice / 100
            else
                TradingLogic.OmniCorpSellRate[msg.m_TokenList[index].m_strAlias] = -999
            end            
            
            --LOG_INFO("Token " .. msg.m_TokenList[index].m_iId .. " has a sellratre of " .. TradingLogic.OmniCorpSellRate[msg.m_TokenList[index].m_strAlias])
            
            -- get the min token Id
            if msg.m_TokenList[index].m_iId < TRADING.iFirstToken then
                TRADING.iFirstToken = msg.m_TokenList[index].m_iId
            end
        end
        
        TradingLogic:InitExchangeRates()
        
    end
end

function TRADING:CheckForCallbacks(_strType, _nID)

 if (TRADING.m_aCallbacks[_strType] ~= nil and TRADING.m_aCallbacks[_strType][_nID] ~= nil) then
 
 	local f = TRADING.m_aCallbacks[_strType][_nID]
 	
 	--LOG_INFO("Callback:" .. tostring(f))
 	
 	f(_nID)
 	
 	local index = 0
 	
 	for k,v in pairs(TRADING.m_aCallbacks[_strType])
 	do
 		if (k == _nID) then
	 		index = index + 1
	 		break
	 	end
 	end
 	
 	table.remove(TRADING.m_aCallbacks[_strType], index)
 end
        
end

function TRADING:CheckCityTokens()

		if cnx == nil then
			return
		end

    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyCityTokens)
    if nil ~= msg then
    
        local iCityId = msg.m_CityTokens.m_iCityId
        
        if iCityId == nil then
            -- this case _is_ a bug
            LOG_ERROR("Not a valid request ID. Don't know the city")
            return
        end
        
        LOG_INFO("City tokens received for "..iCityId )

        TRADING.CityTokens[iCityId] = {}
        TRADING.CityTokens[iCityId].m_FreightCapacity 	= msg.m_CityTokens.m_FreightCapacity
        TRADING.CityTokens[iCityId].m_UsedFreight 		= msg.m_CityTokens.m_UsedFreight
        TRADING.CityTokens[iCityId].m_PassengerCapacity = msg.m_CityTokens.m_PassengerCapacity
        TRADING.CityTokens[iCityId].m_UsedPassenger 	= msg.m_CityTokens.m_UsedPassenger
                
        for idx = 0, msg.m_CityTokens.m_TokenList:size() - 1
        do
            local tmpUsage = msg.m_CityTokens.m_TokenList[idx]
            
            local key = TradingLogic:GetTokenName(tmpUsage.m_iTokenId) 

            TRADING.CityTokens[iCityId][key] = {}
            TRADING.CityTokens[iCityId][key].id               = tmpUsage.m_iTokenId
            TRADING.CityTokens[iCityId][key].production       = tmpUsage.m_iProduction 
            -- changed: only the raw result (imported - exported) is displayed
            TRADING.CityTokens[iCityId][key].imported         = tmpUsage.m_iContracts 
            TRADING.CityTokens[iCityId][key].exported         = 0
            TRADING.CityTokens[iCityId][key].committedToOffer = 0
            TRADING.CityTokens[iCityId][key].ToCity           = 0
            TRADING.CityTokens[iCityId][key].assignedCity     = 0
            TRADING.CityTokens[iCityId][key].assignedProject  = tmpUsage.m_iAllocToProjects
            
            TRADING.CityTokens[iCityId][key].available		  = tmpUsage.m_iProduction + tmpUsage.m_iContracts - tmpUsage.m_iAllocToProjects
			TRADING.CityTokens[iCityId][key].current		  = TRADING.CityTokens[iCityId][key].available		    
--[[
            LOG_INFO("Tokens ".. key .. " - production: " .. TRADING.CityTokens[iCityId][key].production ..
                                         " - contracts: " .. TRADING.CityTokens[iCityId][key].imported .. 
                                         " - allocs: "    .. TRADING.CityTokens[iCityId][key].assignedProject..
										 " - available: "  ..TRADING.CityTokens[iCityId][key].available)
]]
        end
        
		TradeWaitMgr:Did(tradeAction.TokenStatus, iCityId)
		TradingLogic:TestArrivals()
       --LOG_INFO("Check for callback after having processed " .. msg.m_CityTokens.m_TokenList:size() .. " tokens !")
       TRADING:CheckForCallbacks("CityTokens", iCityId);
    end
end

function TRADING:CheckCityContracts()

		if cnx == nil then
			return
		end

    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyCityContracts)
    if nil ~= msg then

        local iCityId = TRADING.CityContractsReq[msg:GetRequestID()]
        if iCityId == nil then
            -- this case _is_ a bug
            LOG_ERROR("Not a valid request ID. Don't know the city")
            return
        end
        
        LOG_INFO("City contracts received for "..iCityId )
        
        TRADING.CityTokenContracts[iCityId] = {}
        for idx = 0, msg.m_Contracts:size() - 1
        do
            local iContractId = msg.m_Contracts[idx].m_iId
            TRADING.CityTokenContracts[iCityId][iContractId] = {}
            TRADING.CityTokenContracts[iCityId][iContractId].m_iId           = msg.m_Contracts[idx].m_iId
            TRADING.CityTokenContracts[iCityId][iContractId].m_iSourceCityId = msg.m_Contracts[idx].m_iSourceCityId
            TRADING.CityTokenContracts[iCityId][iContractId].m_iDestCityId   = msg.m_Contracts[idx].m_iDestCityId
            TRADING.CityTokenContracts[iCityId][iContractId].m_iState        = msg.m_Contracts[idx].m_iState
			--InterfaceUtilities:LOG_CUSTOM1("this contract is to "..(TRADING.CityTokenContracts[iCityId][iContractId].m_iDestCityId or "nil").." and has the state "..TradingLogic:ContractStateToString(TRADING.CityTokenContracts[iCityId][iContractId].m_iState))
            TRADING.CityTokenContracts[iCityId][iContractId].m_CreationDate  = msg.m_Contracts[idx].m_CreationDate
            TRADING.CityTokenContracts[iCityId][iContractId].m_EndDate       = msg.m_Contracts[idx].m_EndDate
            TRADING.CityTokenContracts[iCityId][iContractId].m_iContractId   = msg.m_Contracts[idx].m_iContractId
			
			TRADING.CityTokenContracts[iCityId][iContractId].m_Tokens = {}
			
			for idx2 = 1, msg.m_Contracts[idx].m_Tokens:size()-1 do
	            TRADING.CityTokenContracts[iCityId][iContractId].m_Tokens[idx2]        = msg.m_Contracts[idx].m_Tokens[idx2]
			end	
			
			
			
        end
		
		TradeWaitMgr:Did(tradeAction.ListContracts,iCityId)
		TradingLogic:TestArrivals()
    end
end	


function TRADING:IsUnboundContractOmnicorp(_OfferID)

	for k,v in pairs (TRADING.UnboundContracts) do 
		if (v[_OfferID] ~= nil) then 
			local SourceCity = v[_OfferID].m_iSourceCityId
			return (TradingLogic:IsCityOmincorp(SourceCity))
		end
			
	end
	
	return false 
end

function TRADING:CheckUnboundContracts()

	if cnx == nil then
		return
	end

	local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyUnboundContracts)
	
	if msg ~= nil
    then
    	local iTokenId = msg.m_iTokenType
    	
    	LOG_INFO("Received unbound contracts for token " .. iTokenId .. " - " .. msg.m_Contracts:size() .. " contracts")
    	
    	TRADING.UnboundContracts[iTokenId] = {}
    	
    	for idx = 0, msg.m_Contracts:size() - 1
        do
            local iId = msg.m_Contracts[idx].m_iId
            TRADING.UnboundContracts[iTokenId][iId] = {}
            TRADING.UnboundContracts[iTokenId][iId].m_iId = msg.m_Contracts[idx].m_iId
            TRADING.UnboundContracts[iTokenId][iId].m_iSourceCityId = msg.m_Contracts[idx].m_iSourceCityId
            TRADING.UnboundContracts[iTokenId][iId].m_CreationDate = msg.m_Contracts[idx].m_CreationDate
            
            TRADING.UnboundContracts[iTokenId][iId].m_TokenId = 0
            TRADING.UnboundContracts[iTokenId][iId].m_Amount = 0
            TRADING.UnboundContracts[iTokenId][iId].m_GlobalPrice = 0
            
            for iTok = 0, msg.m_Contracts[idx].m_Tokens:size() - 1
            do
                if( iTok ~= TRADING.iCashIndex and msg.m_Contracts[idx].m_Tokens[iTok] ~= 0)
                then
                    TRADING.UnboundContracts[iTokenId][iId].m_TokenId = iTok
                    TRADING.UnboundContracts[iTokenId][iId].m_Amount = msg.m_Contracts[idx].m_Tokens[iTok]
                    TRADING.UnboundContracts[iTokenId][iId].m_GlobalPrice = math.abs(msg.m_Contracts[idx].m_Tokens[TRADING.iCashIndex])
                    break
                end
            end

            if( TRADING.UnboundContracts[iTokenId][iId].m_TokenId == 0)
            then
                LOG_ERROR( "Unbound contract " .. iId .. " does not specify a token type?!")
                TRADING.UnboundContracts[iTokenId][iId] = {}
            end
            
            --LOG_INFO("Read a new contract: " .. TRADING.UnboundContracts[iTokenId][iId].m_iSourceCityId 
            --.. " deals " .. TRADING.UnboundContracts[iTokenId][iId].m_Amount 
            --.. " tokens " .. TRADING.UnboundContracts[iTokenId][iId].m_TokenId
            --.. " for " .. TRADING.UnboundContracts[iTokenId][iId].m_GlobalPrice .. "$")
            
        end    	
		TradingHouse:PushUnboundList(iTokenId, TRADING.UnboundContracts[iTokenId])
		
		TradeWaitMgr:Did(tradeAction.GetMarket,iTokenId)
		
		
    end
	
end

function TRADING:CheckTokenPriceHistory()

		if cnx == nil then
			return
		end
		
    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyTokenPriceHistory)
    if msg ~= nil
    then
        
        local iTokenId = msg.m_TokenId
		
		TradeWaitMgr:Did(tradeAction.PriceHistory,iTokenId)

        TRADING.TokenPriceHistory[iTokenId] = {}

        for idx = 0, msg.m_PriceList:size() - 1
        do
            TRADING.TokenPriceHistory[iTokenId][msg.m_PriceList[idx].m_iSecSince1970] = msg.m_PriceList[idx].m_iUnitPrice
        end
    end
end


function TRADING:CheckTokenSearch()

		if cnx == nil then
			return
		end

    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyTokenSearch)

    if msg ~= nil
    then

        TRADING.TokenSearchResult = {}
        TRADING.TokenSearchResult.m_bResultReceived = true

        for idx = 0, msg.m_ResultList:size() - 1
        do
            local iCityId = msg.m_ResultList[idx].m_CityId

            TRADING.TokenSearchResult[iCityId]              = {}
            TRADING.TokenSearchResult[iCityId].m_CityId     = msg.m_ResultList[idx].m_CityId
            TRADING.TokenSearchResult[iCityId].m_Distance   = msg.m_ResultList[idx].m_Distance
            TRADING.TokenSearchResult[iCityId].m_CityTokens = msg.m_ResultList[idx].m_CityTokens
        end
		
		TradingLogic:TestArrivals()
    end
end

function TRADING:CheckNotification()

		if cnx == nil then
			return
		end
		
    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyChange)

    -- we may have several notif in a row. Let us loop.
    while msg ~= nil
    do
        local OutMessage = {}

        OutMessage.Code = msg.m_Code
        OutMessage.ObjectId = msg.m_ObjectId
        OutMessage.Param1 = msg.m_Param1
        OutMessage.Param2 = msg.m_Param2
        OutMessage.Param3 = msg.m_Param3
        OutMessage.Param4 = msg.m_Param4
        OutMessage.What = "-"

        table.insert( TRADING.NotificationOut, OutMessage)
        LOG_INFO("Notification received : code"..OutMessage.Code.." for object "..OutMessage.ObjectId)
        msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyChange)
    end

    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyBpChange)
    while msg ~= nil
    do
        local OutMessage = {}

        OutMessage.Code = msg.m_Code
        OutMessage.ObjectId = msg.m_ObjectId
        OutMessage.Param1 = msg.m_Param1
        OutMessage.Param2 = msg.m_Param2
        OutMessage.Param3 = msg.m_Param3
        OutMessage.Param4 = msg.m_Param4
        OutMessage.What = "-"

        table.insert( TRADING.NotificationBpOut, OutMessage)
		LOG_INFO("Notification received : code"..OutMessage.Code.." for object "..OutMessage.ObjectId)
        msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyBpChange)
    end
    
    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyNewOffer)
    while msg ~= nil
    do
        local iOfferId = msg.m_Offer.m_iId
        local iSourceCityId = msg.m_Offer.m_iSourceCityId
        local iDestCityId = msg.m_Offer.m_iDestCityId
        
        LOG_INFO("Received a new offer")
        
        for iCityId in pairs({ iSourceCityId, iDestCityId })
        do
        
            TRADING.CityTokenContracts[iCityId] = TRADING.CityTokenContracts[iCityId] or {}
            
            TRADING.CityTokenContracts[iCityId][iOfferId] = {}
            TRADING.CityTokenContracts[iCityId][iOfferId].m_iId = msg.m_Offer.m_iId
            TRADING.CityTokenContracts[iCityId][iOfferId].m_iSourceCityId = msg.m_Offer.m_iSourceCityId
            TRADING.CityTokenContracts[iCityId][iOfferId].m_iDestCityId = msg.m_Offer.m_iDestCityId
            TRADING.CityTokenContracts[iCityId][iOfferId].m_iState = msg.m_Offer.m_iState
            TRADING.CityTokenContracts[iCityId][iOfferId].m_CreationDate = msg.m_Offer.m_CreationDate
            TRADING.CityTokenContracts[iCityId][iOfferId].m_EndDate = msg.m_Offer.m_EndDate
            TRADING.CityTokenContracts[iCityId][iOfferId].m_iContractId = msg.m_Offer.m_iContractId
    
            TRADING.CityTokenContracts[iCityId][iOfferId].m_Tokens = msg.m_Offer.m_Tokens
        end
        
        TradingLogic:NewOfferRecieved(iOfferId, iSourceCityId)
		LOG_INFO("!!!!!!!!!!!! NewOfferRecieved !!!!!!!!!!!")
        msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyNewOffer)
    end
    
    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyNewContract)
    while msg ~= nil
    do
        local iContractId = msg.m_Offer.m_iId
        local iSourceCityId = msg.m_Offer.m_iSourceCityId
        local iDestCityId = msg.m_Offer.m_iDestCityId
        
        LOG_INFO("Received a new contract")
		
		if (TradingLogic:IsCityOmincorp(iSourceCityId) or TradingLogic:IsCityOmincorp(iDestCityId)) then 
			TradeWaitMgr:Did(tradeAction.AcceptOmnicorpOffer, 0)
		else	
			TradeWaitMgr:Did(tradeAction.AcceptOffer,iContractId)
		end	
        
        for iCityId in pairs({ iSourceCityId, iDestCityId })
        do
            TRADING.CityTokenContracts[iCityId] = TRADING.CityTokenContracts[iCityId] or {}
            TRADING.CityTokenContracts[iCityId][iContractId] = {}
            TRADING.CityTokenContracts[iCityId][iContractId].m_iId           = msg.m_Offer.m_iId
            TRADING.CityTokenContracts[iCityId][iContractId].m_iSourceCityId = msg.m_Offer.m_iSourceCityId
            TRADING.CityTokenContracts[iCityId][iContractId].m_iDestCityId   = msg.m_Offer.m_iDestCityId
            TRADING.CityTokenContracts[iCityId][iContractId].m_iState        = netapi.traContractState_ACTIVE
            TRADING.CityTokenContracts[iCityId][iContractId].m_CreationDate  = msg.m_Offer.m_CreationDate
            TRADING.CityTokenContracts[iCityId][iContractId].m_EndDate       = msg.m_Offer.m_EndDate
            TRADING.CityTokenContracts[iCityId][iContractId].m_iContractId   = msg.m_Offer.m_iContractId
    
            TRADING.CityTokenContracts[iCityId][iContractId].m_Tokens = msg.m_Offer.m_Tokens
        end
        
        TradingLogic:NewContractRecieved(iContractId, iSourceCityId, iDestCityId)
        
        TradingLogic.CityStatsDone = false
        TradingLogic:CheckStats()
        
        if cnx then
	        msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyNewContract)
	      end
    end
    
end


-- Blueprints and GPs

function TRADING:CheckOffline()

	if ((cnx) and (TradingLogic:OfflineMode()==false)) then 
		return false
	else
		return true
	end

end

function TRADING:CheckOnline()

	return (TRADING:CheckOffline()==false)

end	

function TRADING:GetPlayerBlueprints()
	if (TRADING:CheckOnline()) then
		cnx:Trading():GetPlayerBlueprints()
	else
		TRADING:CheckGpProgress()
	end
end

--[[
function TRADING:GetGpProgress()
	if cnx then
		cnx:Trading():GetGpProgress()
	end
end
]]
-- _Allocation is a table, formatted such as:
-- _Allocation = {}
-- _Allocation.m_iCityId = 0
-- _Allocation.m_iGpId = 12
-- _Allocation[3] = 2           // 2 tokens for type 3 (FUEL)
-- _Allocation[4] = 1           // 1 token for type 4 (WORKER1)
function TRADING:AllocateToken( _Allocation)

	if (g_AllocList == nil)
	then
		g_AllocList = netapi.traTokenAllocationVector()
	end
	if (g_Alloc == nil)
	then
		g_Alloc = netapi.traTokenAllocation()
	end

	g_AllocList:clear()

	g_Alloc.m_iCityId = _Allocation.m_iCityId or 0
	g_Alloc.m_iGpId = _Allocation.m_iGpId or 0

	if _Allocation.m_iCityId == nil or _Allocation.m_iGpId == nil
	then
		LOG_ERROR("On a token_allocation, you must specify both a CityId AND a GpId.")
		return
	end

	g_Alloc.m_vTokenAmount:clear()

	for i = 0, TRADING.NbTokenTypes do 
		--LOG_ERROR("__Allocation["..i.."] == "..tostring(_Allocation[i]))
		g_Alloc.m_vTokenAmount:push_back(_Allocation[i] or 0)
	end
	g_AllocList:push_back(g_Alloc)

	if (TRADING:CheckOnline()) then
		cnx:Trading():AllocateToken(g_AllocList)
	end
end

-- Note: returns allocated token for the day (ie. as long as I don't receive a
-- new NotifyCityAllocated())
function TRADING:GetCityAllocated( _iCityId)
	
	if TRADING:CheckOnline() then
		cnx:Trading():GetCityAllocated( _iCityId)
	else
		TRADING:CheckGpProgress()
	end
	
end

function TRADING:GetGpProgress()
	if TRADING:CheckOnline() then
		cnx:Trading():GetGpProgress()
	else
		TRADING:CheckGpProgress()
	end
end

TRADING.CheckGpProgress_DelayedTab = {}

function TRADING:CheckGpProgressDelayed(TimerNext)

	TRADING.CheckGpProgress_DelayedTab = TRADING.CheckGpProgress_DelayedTab or {}
	if TRADING.CheckGpProgress_DelayedTab[TimerNext] ~= true then
		local TimersInfo = {}
				
		Time:GetAllTimersInfo( TimersInfo )
		local Timer = TimersInfo.Timers[TimersInfo.ActiveTimerIndex];
		local TimerNow = (Timer.Turn * 60) + Timer.Step
		local TimerRest = TimerNext - TimerNow + 1 
		
		if (TimerRest <= 0) then
			TRADING:CheckGpProgress()
		else
			TRADING.CheckGpProgress_DelayedTab[TimerNext] = true
			DelayedTasks:AddtaskForce("TRADING:CheckGpProgress", {delayed = true, delayedid = TimerNext}, TimerRest)
		end
	end
end

function TRADING:CheckGpProgress(delayed_param)
	
	local delayed_param = delayed_param or {}
	local delayed = delayed_param.delayed or false
	local delayedid = delayed_param.delayedid or 0
		
	if delayed == true then
		TRADING.CheckGpProgress_DelayedTab[delayedid] = nil
	end
	
	if (TRADING:CheckOffline()) then
		local iCityId = TradingLogic:GetCurrentCityId()
		local isUpdated = false
		
		--ShowTableElementInLog(_BPTab, "BluePrintsInCity")
		--ME:Print_r(_BPTab, "_BPTab : ")
		
		TRADING:CheckInitBlueprints()
		
		TRADING.CityGp[iCityId] = TRADING.CityGp[iCityId] or {}
		
		if (next(TRADING.CityGp[iCityId]) == nil
			and MapSaveMgr.SaveNameTable[iCityId] ~= nil
			and MapSaveMgr.SaveNameTable[iCityId].BluePrints ~= nil
			and next(MapSaveMgr.SaveNameTable[iCityId].BluePrints) ~= nil) then
			
			TRADING.CityGp[iCityId] = {}
			
			for k,v in pairs(MapSaveMgr.SaveNameTable[iCityId].BluePrints) do 
				k = tonumber(k)
				
				TRADING.CityGp[iCityId][k] = {}
				TRADING.CityGp[iCityId][k] = {}
				TRADING.CityGp[iCityId][k].m_iGpCityId  = tonumber(v.m_iGpCityId)
				TRADING.CityGp[iCityId][k].m_iBpType    = tonumber(v.m_iBpType)
				TRADING.CityGp[iCityId][k].m_iGpId      = tonumber(v.ProjectID)
				TRADING.CityGp[iCityId][k].m_iCityId    = v.m_iCityId
				TRADING.CityGp[iCityId][k].m_iProgress  = tonumber(v.m_iProgress)
				TRADING.CityGp[iCityId][k].m_iCurPhase  = tonumber(v.m_iCurPhase)
				TRADING.CityGp[iCityId][k].m_vTokenProgress = {}
				
				for iTokenId, tokV in pairs(v.m_vTokenProgress) do
					iTokenId = tonumber(iTokenId)
					TRADING.CityGp[iCityId][k].m_vTokenProgress[iTokenId] = {}
					TRADING.CityGp[iCityId][k].m_vTokenProgress[iTokenId].m_iNeeded = tonumber(tokV.m_iNeeded)
					TRADING.CityGp[iCityId][k].m_vTokenProgress[iTokenId].m_iAlreadySent = tonumber(tokV.m_iAlreadySent)
					TRADING.CityGp[iCityId][k].m_vTokenProgress[iTokenId].m_iAlocated = tonumber(tokV.m_iAlocated)
					TRADING.CityGp[iCityId][k].m_vTokenProgress[iTokenId].m_iTimerNext = tonumber(tokV.m_iTimerNext)
					TRADING.CityGp[iCityId][k].m_vTokenProgress[iTokenId].m_iPercent = tonumber(tokV.m_iPercent)
				end
			end
			
			TRADING.CityGp[iCityId] = InterfaceUtilities:DeepCopyTable(MapSaveMgr.SaveNameTable[iCityId].BluePrints)
			isUpdated = true
		end
		
		TRADING.GpTokenAllocs[iCityId] = TRADING.GpTokenAllocs[iCityId] or {}
		TRADING.GpTokenAllocsByName[iCityId] = TRADING.GpTokenAllocsByName[iCityId] or {}
		
		--if (next(TRADING.CityGp[iCityId]) == nil) then
		if true then
			local BlueprintProjectsInfo = {}
			
			City:GetBlueprintProjectsInfo( BlueprintProjectsInfo )
			
			if (next (BlueprintProjectsInfo) ~=  nil) then
				local TimersInfo = {}
				
				Time:GetAllTimersInfo( TimersInfo )
				local Timer = TimersInfo.Timers[TimersInfo.ActiveTimerIndex];
				local GmTimeNow = (Timer.Turn * 60) + Timer.Step
				
				for _Alias,_ProjectsTable in pairs (BlueprintProjectsInfo) do 
					local BPId = TradingLogic.GetBPIdFromAlias(_Alias)
					local _bpD = TRADING.BpDesc[BPId]
					
					for k,v in pairs(_ProjectsTable) do 
						local already = false
						
						if TRADING.CityGp[iCityId][v.ProjectID] ~= nil then
							already = true
						end
						
						local nxtStep = v.Step + 1
						if (nxtStep  > 4) then 
							nxtStep = 4
						end
						
						local Limit = TradingLogic:GetLimit()
						
						TRADING.GpTokenAllocs[iCityId][v.ProjectID] = TRADING.GpTokenAllocs[iCityId][v.ProjectID] or {}
						TRADING.GpTokenAllocsByName[iCityId][v.ProjectID] = TRADING.GpTokenAllocsByName[iCityId][v.ProjectID] or {}
						
						if ((already == true) and (TRADING.CityGp[iCityId][v.ProjectID].m_iProgress < 100 or TRADING.CityGp[iCityId][v.ProjectID].m_iCurPhase ~= nxtStep)) then
							local m_iProgress = 0
							local ProgressFirst = true
							local Zeroing = false
							
							if TRADING.CityGp[iCityId][v.ProjectID].m_iCurPhase ~= nxtStep then
								TRADING.CityGp[iCityId][v.ProjectID].m_iCurPhase = nxtStep
								isUpdated = true
								Zeroing = true
							end
							
							for iTokenId = 1, Limit do
								local m_iNeeded = TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iNeeded
								local o_iAlreadySent = TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlreadySent
								
								if o_iAlreadySent > m_iNeeded then
									o_iAlreadySent = m_iNeeded
									TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlreadySent = o_iAlreadySent
								end
								
								local m_iPercent = 0
								
								if m_iNeeded > 0 and o_iAlreadySent > 0 then
									m_iPercent = math.floor(o_iAlreadySent / m_iNeeded * 100)
								end
								
								if Zeroing then
									TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlocated = 0
									TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iTimerNext = 0
									
									local TokName = TradingLogic:GetTokenName(iTokenId)
									
									TRADING.GpTokenAllocs[iCityId][v.ProjectID][iTokenId] = 0
									TRADING.GpTokenAllocsByName[iCityId][v.ProjectID][TokName] = 0
								else
								
									local m_iAlocated = TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlocated
									local m_iTimerNext = TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iTimerNext
								
									if (m_iTimerNext <= GmTimeNow and m_iNeeded > 0 and m_iAlocated > 0) then
										local m_iAlreadySent = o_iAlreadySent
										local phaseMax = _bpD.m_vPhases[nxtStep][iTokenId].m_iTotalAmount
										local phaseDayMax = _bpD.m_vPhases[nxtStep][iTokenId].m_iMaxAmountDay
										local phaseUsed = m_iAlreadySent
									
										--for StepNum, StepVal in pairs(_bpD.m_vPhases) do
											--if StepNum < nxtStep then
												--phaseUsed = phaseUsed - StepVal[iTokenId].m_iTotalAmount
											--end
										--end
									
										if phaseUsed > phaseMax then
											phaseUsed = phaseMax
										end
									
										local SentRest = phaseMax - phaseUsed
									
										--LOG_ERROR("bpid : " .. tostring(v.ProjectID) .. " : " .. tostring(GmTimeNow) .. " vs " .. tostring(m_iTimerNext))
										--LOG_ERROR("Timer.Turn : " .. tostring(Timer.Turn) .. " Timer.Step : " .. tostring(Timer.Step))
									
										if SentRest <= m_iAlocated then
											--LOG_ERROR("last added : " .. tostring(SentRest))
											m_iAlreadySent = o_iAlreadySent + SentRest
											m_iAlocated = 0
											TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlocated = m_iAlocated
											m_iTimerNext = 0
										else
											m_iAlreadySent = o_iAlreadySent + m_iAlocated
											--LOG_ERROR("added : " .. tostring(m_iAlocated))
											m_iTimerNext = m_iTimerNext + 60
										end
										
										TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iTimerNext = m_iTimerNext

										--LOG_ERROR("now : " .. tostring(m_iAlreadySent))
									
										TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlreadySent = m_iAlreadySent
										m_iPercent = math.floor(m_iAlreadySent / m_iNeeded * 100)
										TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iPercent = m_iPercent
									
										isUpdated = true
									end
								
									local TokName = TradingLogic:GetTokenName(iTokenId)
					
									TRADING.GpTokenAllocs[iCityId][v.ProjectID][iTokenId] = m_iAlocated
									TRADING.GpTokenAllocsByName[iCityId][v.ProjectID][TokName] = m_iAlocated
									
									if m_iAlocated > 0 then
										TRADING:CheckGpProgressDelayed(m_iTimerNext)
									end
								end
								
								if m_iNeeded > 0 then
									--LOG_ERROR("TokId : " .. tostring(iTokenId) .. " Needed : " .. tostring(m_iNeeded) .. " AlreadySent : " .. tostring(TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlreadySent) .. " Percent : " .. tostring(m_iPercent))
									if ProgressFirst == true then
										ProgressFirst = false
										m_iProgress = m_iPercent
									else
										m_iProgress = math.floor((m_iProgress + m_iPercent) / 2)
									end
								end
							end
							
							TRADING.CityGp[iCityId][v.ProjectID].m_iProgress = m_iProgress
							
						elseif (already == false) then
							isUpdated = true
							
							TRADING.CityGp[iCityId][v.ProjectID] = {}
							TRADING.CityGp[iCityId][v.ProjectID].m_iGpCityId  = v.ProjectID
							TRADING.CityGp[iCityId][v.ProjectID].m_iBpType    = BPId
							TRADING.CityGp[iCityId][v.ProjectID].m_iGpId      = v.ProjectID
							TRADING.CityGp[iCityId][v.ProjectID].m_iCityId    = iCityId
							TRADING.CityGp[iCityId][v.ProjectID].m_iProgress  = 0
							TRADING.CityGp[iCityId][v.ProjectID].m_iCurPhase  = nxtStep
							TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress = {}							
						
							local _Needed_token = {}

							for pId,pV in pairs(_bpD.m_vPhases) do
								for tId,tV in pairs(pV) do
									_Needed_token[tV.m_iTokenId] = tV.m_iTotalAmount
								end
							end
							
							for iTokenId = 1, Limit do 
								TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId] = {}
								if _Needed_token[iTokenId] == nil then
									TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iNeeded = 0
								else
									TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iNeeded = _Needed_token[iTokenId]
								end
								TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlreadySent = 0
								TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iAlocated = 0
								TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iTimerNext = 0
								TRADING.CityGp[iCityId][v.ProjectID].m_vTokenProgress[iTokenId].m_iPercent = 0
								
								local TokName = TradingLogic:GetTokenName(iTokenId)
					
								TRADING.GpTokenAllocs[iCityId][v.ProjectID][iTokenId] = 0
								TRADING.GpTokenAllocsByName[iCityId][v.ProjectID][TokName] = 0
							end
							
						end
						
						
					end
					
				end
			end
		end
		
		--ME.Print_r(TRADING.CityGp, "ME: TRADING.CityGp : ")
		
		--LOG_ERROR("ME::::: " .. tostring(TRADING.CityGp))
		if isUpdated == true then
			TradingLogic:GPProgressArrived()
		end
		
		return
	end

	local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyGpProgress)
	if nil ~= msg then

        -- fake message 
        
            --[[if (false) then 
        
            local _BPTab = TradingLogic.GetLocalBluePrints()
            
            ShowTableElementInLog(_BPTab, "BluePrintsInCity")
            
            local nb = 0
            
            
            
            for k,v in pairs (_BPTab) do 
                nb = nb + 1 
                --LOG_INFO("GP Progress message recieved")
                
                local nxtStep = v._Step +1
                if (nxtStep  > 4) then 
                    nxtStep = 4
                end    
                
                TRADING.CityGp[ nb] = {}
                TRADING.CityGp[ nb].m_iGpCityId  = v.ProjectID
                TRADING.CityGp[ nb].m_iBpType    = v.BPId
                TRADING.CityGp[ nb].m_iCityId    = TradingLogic:GetCurrentCityId()
                TRADING.CityGp[ nb].m_iProgress  = nxtStep * 25
                TRADING.CityGp[ nb].m_iCurPhase  = nxtStep
            end    
        
        else]]
		-- LOG_ERROR("received GP status")
		local bFirst = {}
		for iGp = 0, msg.m_GpProgressList:size()-1 do
			-- idenitifiant unique d'une instance d'une BP dans une ville -> un GP.
			local iGpId = msg.m_GpProgressList[iGp].m_iGpCityId
			local iCityId = msg.m_GpProgressList[iGp].m_iCityId
			if( bFirst[ iCityId] == nil)
			then
				TRADING.CityGp[ iCityId] = {}
				bFirst[ iCityId] = iCityId
			end
			
			TRADING.CityGp[ iCityId][ iGpId] = {}
			TRADING.CityGp[ iCityId][ iGpId].m_iGpCityId  = msg.m_GpProgressList[iGp].m_iGpCityId
			TRADING.CityGp[ iCityId][ iGpId].m_iBpType    = msg.m_GpProgressList[iGp].m_iBpType
			TRADING.CityGp[ iCityId][ iGpId].m_iGpId        = iGpId
			TRADING.CityGp[ iCityId][ iGpId].m_iCityId    = msg.m_GpProgressList[iGp].m_iCityId
			TRADING.CityGp[ iCityId][ iGpId].m_iProgress  = msg.m_GpProgressList[iGp].m_iProgress
			TRADING.CityGp[ iCityId][ iGpId].m_iCurPhase  = msg.m_GpProgressList[iGp].m_iCurPhase
			TRADING.CityGp[ iCityId][ iGpId].m_vTokenProgress = {}        -- progress for the *current phase*

			-- LOG_INFO( "City " .. TRADING.CityGp[ iCityId][ iGpId].m_iCityId .. ", GP: " .. iGpId .. " (from Blueprint " .. TRADING.CityGp[ iCityId][ iGpId].m_iBpType .. ") - Progress: " .. TRADING.CityGp[ iCityId][ iGpId].m_iProgress)

			for iTokPhase = 0, msg.m_GpProgressList[iGp].m_vTokenProgress:size()-1
			do
				local iTokenId = msg.m_GpProgressList[iGp].m_vTokenProgress[iTokPhase].m_iTokenId

				TRADING.CityGp[ iCityId][ iGpId].m_vTokenProgress[iTokenId] = {}
				TRADING.CityGp[ iCityId][ iGpId].m_vTokenProgress[iTokenId].m_iNeeded = msg.m_GpProgressList[iGp].m_vTokenProgress[iTokPhase].m_iNeeded
				TRADING.CityGp[ iCityId][ iGpId].m_vTokenProgress[iTokenId].m_iAlreadySent = msg.m_GpProgressList[iGp].m_vTokenProgress[iTokPhase].m_iAlreadySent
				-- LOG_ERROR("Already sent of "..iTokenId.." = "..TRADING.CityGp[ iGpId].m_vTokenProgress[iTokenId].m_iAlreadySent.." to "..iGpId)
			end
			
			-- LOG_INFO(" Need / Alloc complete")

		end
--end
		TradingLogic:GPProgressArrived()
    end
end


--FileSystem:DoFile("data/design/script/network/trading.lua") 
    
function TRADING:CheckGetCityAllocated()

	if (TRADING:CheckOffline()) then
		TRADING:CheckGpProgress()
		return
	end

	local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyCityAllocated)



	if (nil ~= msg) then
		--LOG_ERROR("Alloc recieved, msg.m_CityTokens:size() = "..msg.m_CityTokens:size())
		
		for iAlloc = 0, msg.m_CityTokens:size()-1 do
			local iId = 0
			--if msg.m_CityTokens[iAlloc].m_iGpId ~= 0
			CityId = msg.m_CityTokens[iAlloc].m_iCityId
			iId = msg.m_CityTokens[iAlloc].m_iGpId

			-- LOG_INFO("Allocation info for GP " .. iId)

			TRADING.GpTokenAllocs[CityId] = TRADING.GpTokenAllocs[CityId] or {} 
			
			TRADING.GpTokenAllocsByName[CityId] = TRADING.GpTokenAllocsByName[CityId] or {} 

			TRADING.GpTokenAllocs[CityId][iId] = {}
			
			TRADING.GpTokenAllocsByName[CityId][iId] = {}

			-- LOG_ERROR("msg.m_CityTokens[iAlloc].m_vTokenAmount:size() -1 === "..tostring(msg.m_CityTokens[iAlloc].m_vTokenAmount:size() -1))
			
			--local id = 0
			
			for iTokId = 1, msg.m_CityTokens[iAlloc].m_vTokenAmount:size() -1 do
				
				--id = id +1
				
				local Name = TradingLogic:GetTokenName(iTokId)
				
				TRADING.GpTokenAllocsByName[CityId][iId][Name] = msg.m_CityTokens[iAlloc].m_vTokenAmount[iTokId]
				
				-- InterfaceUtilities:LOG_CUSTOM1("msg.m_CityTokens[iAlloc].m_vTokenAmount["..iTokId.."] === "..tostring(msg.m_CityTokens[iAlloc].m_vTokenAmount[iTokId]))
				table.insert(TRADING.GpTokenAllocs[CityId][iId], msg.m_CityTokens[iAlloc].m_vTokenAmount[iTokId])
			end

		end
		-- ShowTableElementInNotepad(TRADING.GpTokenAllocs[CityId], "TRADING.GpTokenAllocs["..CityId.."]")
	else
		-- LOG_ERROR("Alloc msg is nil")
	end
end

function TRADING:CheckAllocateToken()

	if (TRADING:CheckOffline()) then
		return
	end

	local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyAllocateToken)
	if nil ~= msg then

		if msg.m_strError == nil or msg.m_strError == ""
		then
			LOG_INFO("Allocation looks OK.")
		else
			LOG_ERROR("Error on AllocateToken(): " .. msg.m_strError)
		end
	end
end

function TRADING:CheckGetPlayerBlueprints()

	if (TRADING:CheckOffline())  then
		
		if next(TRADING.PlayerBp) == nil then
			TRADING.PlayerBp = {}
				
			for k, v in pairs(TRADING.BpDesc) do
				--LOG_ERROR("ME:CheckGetPlayerBlueprints :: " .. tostring(v.m_strAlias) .. " --- " .. tostring(v.m_vPhases))
				if (v.m_vPhases and next(v.m_vPhases) ~= nil) then
					--LOG_ERROR("ME:CheckGetPlayerBlueprints -- added :: " .. tostring(v.m_strAlias))
					TRADING.PlayerBp[k] = v.m_strAlias
					TRADING:ShowPlayerBlueprintsInGame(v.m_strAlias)
				end
				--if v.m_vPhases ~= nil and  v.m_vPhases:size() > 0 then
				
				--end
			end
		end
		
		return
	end

	local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyPlayerBlueprints)
	if nil ~= msg then

		-- LOG_INFO( msg.m_Blueprints:size() .. " Blueprints for player.")

		TRADING.PlayerBp = {}
		for index = 0, msg.m_Blueprints:size()-1
		do
			local iBpId = msg.m_Blueprints[index]
	--            LOG_INFO( "BP: " .. tostring(iBpId))
			if (nil ~= TRADING.BpDesc[ iBpId]) then
				TRADING.PlayerBp[ iBpId] = TRADING.BpDesc[ iBpId].m_strAlias or "[Unknown blueprint]"
				-- LOG_INFO("Player has activated: " .. TRADING.BpDesc[ iBpId].m_strAlias)
				TRADING:ShowPlayerBlueprintsInGame(TRADING.BpDesc[ iBpId].m_strAlias)
			end
		end
	end
end

function TRADING:ShowPlayerBlueprintsInGame(_bpName)
    -- LOG_ERROR("Activating BP with ID :".._bpName)
	
	--if (TRADING:CheckOffline()) then 
	--	return 
	--end	
	
    Command:Post("BLUEPRINT","BLUEPRINTAVAILABLE", _bpName)

end

function TRADING:GetBPIdFromName(_name)

    for k,v in pairs (TRADING.BpDesc) do
    
        if (v.m_strAlias == _name) then 
            return k
        end    
    end
    
    return -1

end

function TRADING:CheckInitBlueprints()

	if (TRADING:CheckOffline()) then 
		if next(TRADING.BpDesc) == nil then
			TRADING.BpDesc = InterfaceUtilities:DeepCopyTable(TRADING.Master.BpDesc)
		end
		return 
	end	
		
    local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuTradingService_NotifyInitBlueprints)
    if nil ~= msg then
        TRADING.NbBpTypes = msg.m_Blueprints:size()
        for index = 0, msg.m_Blueprints:size()-1
        do
            local iBpId = msg.m_Blueprints[index].m_iId
            TRADING.BpDesc[ iBpId] = {}
            TRADING.BpDesc[ iBpId].m_iGpId = msg.m_Blueprints[index].m_iGpId
            TRADING.BpDesc[ iBpId].m_strAlias = msg.m_Blueprints[index].m_strAlias
            TRADING.BpDesc[ iBpId].m_bIsMega = msg.m_Blueprints[index].m_bIsMega
            TRADING.BpDesc[ iBpId].m_vPhases = {}

            --LOG_INFO("Blueprint [" .. tostring(iBpId) .. "] = " .. TRADING.BpDesc[ iBpId].m_strAlias)

            for iPhase = 0, msg.m_Blueprints[index].m_vPhases:size()-1
            do
                local iPhaseId = msg.m_Blueprints[index].m_vPhases[iPhase].m_iPhaseNb
                TRADING.BpDesc[ iBpId].m_vPhases[iPhaseId] = {}

               -- LOG_INFO("    Phase " .. tostring(iPhaseId))

                for iTok = 0, msg.m_Blueprints[index].m_vPhases[iPhase].m_vCost:size()-1
                do
                    local iTokId = msg.m_Blueprints[index].m_vPhases[iPhase].m_vCost[iTok].m_iTokenId
                   -- LOG_INFO("        Token " .. tostring(iTokId) .. " to allocate: " ..
                    --    tostring(msg.m_Blueprints[index].m_vPhases[iPhase].m_vCost[iTok].m_iTotalAmount)
                     --   .. "(" .. tostring(msg.m_Blueprints[index].m_vPhases[iPhase].m_vCost[iTok].m_iMaxAmountDay) .. " max per day)")

                    TRADING.BpDesc[ iBpId].m_vPhases[iPhaseId][iTokId] = {}
                    TRADING.BpDesc[ iBpId].m_vPhases[iPhaseId][iTokId].m_iTokenId = iTokId
                    TRADING.BpDesc[ iBpId].m_vPhases[iPhaseId][iTokId].m_iTotalAmount = msg.m_Blueprints[index].m_vPhases[iPhase].m_vCost[iTok].m_iTotalAmount
                    TRADING.BpDesc[ iBpId].m_vPhases[iPhaseId][iTokId].m_iMaxAmountDay = msg.m_Blueprints[index].m_vPhases[iPhase].m_vCost[iTok].m_iMaxAmountDay

                end
            end
        end
    end
end

function TRADING:IsAMultiTag(_multiName)

--[[
	if (TRADING:IsOnline()==false) then 
		return false
	end
	
	if (TRADING.MultiAlias ~= nil) then 
		return (TRADING.MultiAlias[_multiName or "nil"] ~= nil)
	end
	]]
	return false
end

function TRADING:AddMulti(_id, _alias, _tokenId)
	
	TRADING.MultiDesc[ _id] = {}
	TRADING.MultiDesc[ _id].id = _id
	TRADING.MultiDesc[ _id].alias = _alias 
	
	TRADING.MultiDesc[ _alias] = {}
	
	TRADING.MultiDesc[ _alias].tokenID = tonumber(_tokenId or 0)
	TRADING.MultiDesc[ _alias].id = _id
	
	TRADING.MultiAlias[_alias] = _id

end


function TRADING:CheckInitMulti()

	if (TRADING:IsOnline()==false) then
		return
	end
	

	if (TRADING.Multinationals ~=false) then 
		local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuSimService_NotifyInitMulti)
	    if nil ~= msg then
		
			InterfaceUtilities:LOG_CUSTOM3(" Multi init message recieved") 
			
			local Response = msg.m_Error.m_nCode
			local Msg = msg.m_Error.m_strMsg
			InterfaceUtilities:LOG_CUSTOM3("TRADING:CheckInitMulti : error code recieved = "..tostring(Response).." msg = "..tostring(Msg) )
			
			TRADING.MultiDesc = {}
			TRADING.MultiAlias = {}
			
			for index = 0, msg.m_vMultiDesc:size()-1
	        do            
				local iMultiId = msg.m_vMultiDesc[index].m_iId 
				--TRADING.MultiDesc[ iMultiId] = {}
				--TRADING.MultiDesc[ iMultiId].id =  tonumber(iMultiId)
				local Alias = msg.m_vMultiDesc[index].m_strAlias  or "nil"
				
				local TokenID = msg.m_vMultiDesc[index].m_iTokenId  or "nil"
				--TRADING.MultiDesc[ iMultiId].alias = Alias
				--TRADING.MultiAlias[Alias] = iMultiId
				
				TRADING:AddMulti(iMultiId, Alias, TokenID)
				--InterfaceUtilities:LOG_CUSTOM3((Alias or "nil").." = "..iMultiId) 
				
	        end
	    end		
	else
	
		--[[
		if (next (TRADING.MultiDesc) == nil) or (next(TRADING.MultiDesc) == nil))
		TRADING.MultiAlias = {}

	
		TRADING:AddMulti(1, "business_lastupg",1)
		TRADING:AddMulti(2, "elec_lastupg",2)
		TRADING:AddMulti(3, "heavyind_lastupg",3)
		TRADING:AddMulti(4, "hightech_lastupg",4)
		TRADING:AddMulti(5, "manuf_lastupg",5)
		TRADING:AddMulti(6, "oil_lastupg",6)
		TRADING:AddMulti(7, "waste_lastupg",7)
		TRADING:AddMulti(8, "water_lastupg",8)
		TRADING:AddMulti(9, "agri_lastupg",9)
		]]
	end
		
	
end

function TRADING:InitOfflineMulti()
--[[
	TRADING.MultiDesc = {}
	TRADING.MultiAlias = {}
	TRADING:AddMulti(1, "business_lastupg",1)
	TRADING:AddMulti(2, "elec_lastupg",2)
	TRADING:AddMulti(3, "heavyind_lastupg",3)
	TRADING:AddMulti(4, "hightech_lastupg",4)
	TRADING:AddMulti(5, "manuf_lastupg",5)
	TRADING:AddMulti(6, "oil_lastupg",6)
	TRADING:AddMulti(7, "waste_lastupg",7)
	TRADING:AddMulti(8, "water_lastupg",8)
	TRADING:AddMulti(9, "agri_lastupg",9)]]
	
end
	

function TRADING:GetMultiProgress(CityId)
	if (TRADING:IsOnline()) then 
		
		CityId = (CityId  or TradingLogic:GetCurrentCityId()) or 0
		if (TRADING.Multinationals) then 	
			cnx:SimNet():GetMultiProgress(CityId)
		end	
	else
		TRADING:InitOfflineMulti()	
	end
	
	
end

function TRADING:CheckMultiProgress()

	if (TRADING:IsOnline()==false) then
		return
	end
	
	if (TRADING.Multinationals ~=false) then 
		local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuSimService_NotifyMultiProgress)
	    if nil ~= msg then
			
			local Response = msg.m_Error.m_nCode
			local Msg = msg.m_Error.m_strMsg
			InterfaceUtilities:LOG_CUSTOM3("TRADING:CheckMultiProgress : error code recieved = "..tostring(Response).." msg = "..Msg )
			
		
			local CityID = msg.m_iCityId
			
			TRADING.CityMulti[CityID] = {}
			
			for index = 0, msg.m_vProgressList:size()-1
	        do            
			
				local iMultiId = msg.m_vProgressList[index].m_iMultiId 
				local Alias = 	TRADING.MultiDesc[ iMultiId].alias 

				local Progress = msg.m_vProgressList[index].m_iProgress  or "nil"
				local TokenID = TRADING.MultiDesc[iMultiId].tokenID  or "nil"
				
				TRADING.CityMulti[CityID][Alias] = {}
				TRADING.CityMulti[CityID][Alias].id =  iMultiId
				TRADING.CityMulti[CityID][Alias].progress =  Progress
				TRADING.CityMulti[CityID][Alias].tokenID =  TokenID
				
				if (Progress == 100) then 
					PlayerManager:AddLevelConditionTag(Alias) 
				else
					PlayerManager:RemoveConditionTag(Alias) 
				end	
				
				
				
				
	        end
	    end		
	end
	
	
end

function TRADING:GetCurrentProgress(Alias, CityId)

	CityId = (CityId  or TradingLogic:GetCurrentCityId()) or 0
	if (TRADING.CityMulti[CityID] == nil) then 
		return 0
	end
	
	if (TRADING.CityMulti[CityID][Alias] == nil) then 
		return 0
	else
		return (TRADING.CityMulti[CityID][Alias].progress or 0)
	end	

end

TRADING.RequestedMulti = TRADING.RequestedMulti  or ""

function TRADING:PrepareBuildMulti(Proto, Alias) 
	if (TRADING:IsOnline()) then 
		
		CityId = (CityId  or TradingLogic:GetCurrentCityId()) or 0
		if (TRADING.Multinationals) then 	
		
			if (Alias == nil) or (TRADING.MultiDesc[ Alias] == nil) then 
				
				InterfaceUtilities:LOG_CUSTOM3("TRADING:PrepareBuildMulti : for Alias "..tostring(Alias).." there is no description")
				return 
			end	
			local MultiId = TRADING.MultiDesc[ Alias].id
			
			TRADING.RequestedMulti = Alias
			CursorMgr:SetCursorType(Cursor.Wait)
			InterfaceUtilities:LOG_CUSTOM3("TRADING:PrepareBuildMulti for "..tostring(Alias))
			cnx:SimNet():PrepareBuildMulti(CityId,MultiId)
		end	
	else
		InterfaceUtilities:LOG_CUSTOM3("TRADING:CheckPrepareBuildMulti : YOU CANNOT BUILD "..tostring(Alias).." offline")
		CursorMgr:SetCursorType(Cursor.Basic) 
		PlayerManager:RemoveConditionTag(TRADING.RequestedMulti) 
	end	
end

function TRADING:IsOnline()

	if (cnx ~= nil) and (TradingLogic:OfflineMode() == false) then 
		return true
	else
	return false
end
end

	


function TRADING:CheckPrepareBuildMulti() 
	if (TRADING:IsOnline()==false) then
		return
	end
	
	if (TRADING.Multinationals ~=false) then 
		local msg = cnx:PopMessageWithType(netapi.cunEContainer_cuSimService_NotifyPrepareBuildMulti)
	    if nil ~= msg then
			local Response = msg.m_Error.m_nCode
			local Msg = msg.m_Error.m_strMsg
			InterfaceUtilities:LOG_CUSTOM3("TRADING:CheckPrepareBuildMulti : error code recieved = "..tostring(Response).." msg = "..Msg )
			
			-- cheat 
			-- Response = 2
			
			if (Response ==2) then 
				InterfaceUtilities:LOG_CUSTOM3("TRADING:CheckPrepareBuildMulti : You can build "..tostring(TRADING.RequestedMulti))
				CursorMgr:SetCursorType(Cursor.Build)
				CONSTRUCTIONMENU2:CanPlaceMultiEntity(TRADING.RequestedMulti )
			else
				-- MESSAGE BOX ?
				InterfaceUtilities:LOG_CUSTOM3("TRADING:CheckPrepareBuildMulti : YOU CANNOT BUILD "..tostring(TRADING.RequestedMulti))
				CursorMgr:SetCursorType(Cursor.Basic) 
				PlayerManager:RemoveConditionTag(TRADING.RequestedMulti) 
				return 
			end
	    end		
	end
end



function TRADING:BuildMulti(Alias) 
		
	if (TRADING:IsOnline()==false) then
		return
	end
	
	CityId = (CityId  or TradingLogic:GetCurrentCityId()) or 0
		
	if (TRADING.Multinationals) then 	
		if (Alias == nil) or (TRADING.MultiDesc[ Alias] == nil) then 
			return 
		end	
		
		local MultiId = TRADING.MultiDesc[ Alias].id
		
		InterfaceUtilities:LOG_CUSTOM4("Sending confirmation to server that building "..Alias.." (id = "..tostring(MultiId)..") was placed")
		
		cnx:SimNet():BuildMulti(CityId,MultiId)
	end
	
end

function TRADING:CheckBuildMulti() 

end

TRADING.LastUpdateTimeStep = 0

-- to integrate in NETWORK:Udpate()
function TRADING:UpdateTrading(UnForce)
	UnForce = UnForce or false
	
	if UnForce then
		local TimersInfo = {}
	
		Time:GetAllTimersInfo( TimersInfo )
		local Timer = TimersInfo.Timers[TimersInfo.ActiveTimerIndex];
		local TimeDiff = Timer.Step - TRADING.LastUpdateTimeStep
	
		if TimeDiff >= 5 or TimeDiff <= -5 then
			TRADING.LastUpdateTimeStep = Timer.Step
		else
			return
		end
	end
	
	if (TRADING:CheckOffline())  then
		TRADING:CheckGpProgress()
	else
	
		TRADING:CheckInitTrading()
		TRADING:CheckInitBlueprints()
		TRADING:CheckCityTokens()
		TRADING:CheckTokenPriceHistory()
		TRADING:CheckCityContracts()
		TRADING:CheckUnboundContracts()
		TRADING:CheckTokenSearch()
		TRADING:CheckNotification()

		TRADING:CheckGetPlayerBlueprints()
		TRADING:CheckAllocateToken()
		TRADING:CheckGetCityAllocated()
		TRADING:CheckGpProgress()
	
		TRADING:CheckInitMulti()
		TRADING:CheckMultiProgress()
		TRADING:CheckPrepareBuildMulti()
	
	end
	
end

FileSystem:DoFile("Data/Design/Script/Network/trading.master")
