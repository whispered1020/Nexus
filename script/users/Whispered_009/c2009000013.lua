--Abyssal Dread Abyst
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Abyssal Dread to hand from deck and Special Summon 1 Aqua, Sea Serpent or Fish monster from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Special Summon 1 Sea Serpent monster from the GY or banishment
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={0xf18}
s.listed_names={2009000013}
--Add Abyssal Dread card to hand and Special Summon from hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end
function s.thfilter(c,ft)
	return c:IsSetCard(0xf18) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(2009000013)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_HAND) and chkc:IsControler(tp) and s.thfilter(chkc,e,tp,ft) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter2(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_AQUA|RACE_SEASERPENT|RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(2009000013)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	 --Cannot Special Summon, except Aqua, Sea Serpent or Fish monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
	  Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
	  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		if Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
      local tg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			Duel.BreakEffect()
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
	end
end
--special summon only Aqua, Sea Serpent or Fish monsters
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_AQUA|RACE_SEASERPENT|RACE_FISH)
end
--Special summon 1 sea serpent monster from GY
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_GRAVE|LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end