--Abyssal Dread Abysent
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from gy and change level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0})
	--e1:SetCondition(aux.exccon)
	e1:SetTarget(s.sptg2)
	e1:SetOperation(s.spop2)
	c:RegisterEffect(e1)
--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,3})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
--Listed of Archetype
s.listed_series={0xf18}
s.listed_names={2009000014}
--Check for Aqua, Sea Serpent or Fish monster
function s.spfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA|RACE_SEASERPENT|RACE_FISH) and c:HasLevel()
end
--Check the Target
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.spfilter2(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
--Activation
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
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
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
	  local lvl=1
		if tc:GetLevel()==1 then
			Duel.SelectOption(tp,aux.Stringid(id,1))
		else
			local sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			if sel==1 then
				lvl=-1
			end
		end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(lvl)
	tc:RegisterEffect(e1)
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			--Banish it if it leaves the field
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(3300)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e2:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
	end
end
--special summon only Aqua, Sea Serpent or Fish monsters
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_AQUA|RACE_SEASERPENT|RACE_FISH)
end
--add to hand and normal Summon
function s.filter(c)
	return c:IsRace(RACE_SEASERPENT) and c:IsMonster() and not c:IsCode(2009000014) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.sumfilter(c)
	return c:IsRace(RACE_SEASERPENT) and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		--Normal summon 1 Sea Serpent monster
		local sg1=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg2=sg1:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sg2,true,nil)
		end
	end
end