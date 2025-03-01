--Mage Penguin
local s,id=GetID()
function s.initial_effect(c)
  c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),1,1,Synchro.NonTuner(nil),1,99)
	-- Place 1 "Penguin" Spell/Trap face-up on the field from your Hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Return 1 of opponent's spells/traps to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- Special Summon 1 "Penguin" monster from Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	--e3:SetCost(s.tgcost)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PENGUIN}
s.listed_names={80893872}
function s.plfilter(c,tp)
	return c:IsSetCard(SET_PENGUIN) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsContinuousSpellTrap() and not c:IsCode(80893872)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
--Filter
function s.rmfilter(c)
	return c:IsSpell() or c:IsTrap()
end
-- Refurn 1 spell/trap of opponent to hand
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE|LOCATION_GRAVE) and chkc:IsAbleToHand() and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_SZONE|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_SZONE|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
	--Return 1 of opponent's spells/traps to hand
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
--Special summon from Deck
function s.stfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_PENGUIN)
end

function s.tgfilter(c,e,tp)
    return c:IsSetCard(0x5a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(s.stfilter,Card.IsAbleToGraveAsCost),tp,LOCATION_SZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,aux.AND(s.stfilter,Card.IsAbleToGrave),tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local g2=Duel.GetFirstTarget()
	if not g2:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	--local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
	  Duel.SendtoGrave(g2,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end