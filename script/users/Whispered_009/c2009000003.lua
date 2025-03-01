--Etherial Magician
local s,id=GetID()
function s.initial_effect(c)
  c:EnableReviveLimit()
--Pendulum Summon
	Pendulum.AddProcedure(c,false)
	--2 Level 7 Spellcaster monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),7,2)
--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
--Negate effect and get pendulum scale
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
--Place this card in the Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
--Grant piercing to 1 dark spellcaster  monster you control
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.dbcon)
	e4:SetTarget(s.dbtg)
	e4:SetOperation(s.pierceop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MAGICIAN}
s.pendulum_level=7
--special summon 
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.spfilter1(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and (c:GetLevel()==4 or c:GetLevel()==7) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- Negate and get pendulum scale
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsChainDisablable(ev) and re:IsMonsterEffect() and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.pendfilter(c)
	return c:IsSetCard(SET_MAGICIAN) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
	if chk==0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_DECK,0,1,nil)  end
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local pg=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if pg then
		Duel.MoveToField(pg,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
	end
end
-- Special summon this card
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- Grant piercing damage to 1 dark spellcaster monster
function s.dbcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.piercefilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:GetFlagEffect(id)==0 and not c:IsHasEffect(EFFECT_PIERCE)
end
function s.dbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.dbfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dbfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.pierceop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--Deals piercing battle damage this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3208)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end