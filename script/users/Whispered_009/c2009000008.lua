--Mirror Penguin Duke
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Penguin Soldier
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.solcon)
	e1:SetCost(s.solcost)
	e1:SetTarget(s.soltarget)
	e1:SetOperation(s.soloperation)
	c:RegisterEffect(e1)
		--Penguin Ninja
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.nincon)
	e2:SetCost(s.nincost)
	e2:SetTarget(s.nintarget)
	e2:SetOperation(s.ninoperation)
	c:RegisterEffect(e2)
	--Add 1 "Penguin" to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function (_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.addtarget)
	e3:SetOperation(s.addoperation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PENGUIN}
s.listed_names={93920745,41255165}

--Penguin Soldier
function s.solcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and re:IsActiveType(TYPE_MONSTER)
end
function s.solcostfilter(c)
	return c:IsSetCard(SET_PENGUIN) and c:IsCode(93920745) and aux.SpElimFilter(c,true) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.solcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.solcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg=Duel.SelectMatchingCard(tp,s.solcostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,rt,nil)
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	e:SetLabel(#cg)
end
function s.soltarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.soloperation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
--Penguin Ninja
function s.nincon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and re:IsSpellTrapEffect()
end
function s.nincostfilter(c)
	return c:IsSetCard(SET_PENGUIN) and c:IsCode(41255165) and aux.SpElimFilter(c,true) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.nincost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nincostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	local rt=Duel.GetTargetCount(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg=Duel.SelectMatchingCard(tp,s.nincostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,rt,nil)
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	e:SetLabel(#cg)
end
function s.nintarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
	--Return up to 2 of opponent's spells/traps to hand
function s.ninoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- Add 1 "Penguin" monster to hand
function s.addfilter(c)
	return c:IsSetCard(SET_PENGUIN) and c:IsMonster() and c:IsAbleToHand()
end
function s.addtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_GRAVE|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_DECK)
end
function s.addoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.addfilter),tp,LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end