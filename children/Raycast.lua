local Raycast = {
	origin = nil,

	target = nil,

	whitelist = nil,

	blacklist = nil,

	ignore_water = false,

	build = function (self, origin: Vector3, target: Vector3, options: { whitelist: {}?, blacklist: {}?, ignore_water: boolean? }?)
		-- optional params
		options = options or {};
		options.whitelist = options.whitelist or nil;
		options.blacklist = options.blacklist or nil;
		options.ignore_water = options.ignore_water or false;

		-- params
		self.origin = origin;
		self.target = target;

		-- options
		if options.whitelist ~= nil then 
			self.whitelist = options.whitelist;
		elseif options.blacklist ~= nil then 
			self.blacklist = options.blacklist;
		end

		-- ignorewater
		if options.ignore_water == true then self.ignore_water = true; end
	end,

	cast = function (self, visible: { name: string?, parent: Instance?, color: Color3, size: number, transparency: number?, material: Enum.Material?, destroy: number? } | nil, gun_behavior: boolean?): RaycastResult | nil
		-- optional params
		gun_behavior = gun_behavior or false;
		if visible ~= nil then
			visible.name = visible.name or "Part";
			visible.parent = visible.parent or workspace;
			visible.material = visible.material or Enum.Material.Plastic;
			visible.transparency = visible.transparency or 0;
			visible.destroy = visible.destroy or nil;
		end

		if self.origin ~= nil and self.target ~= nil then
			local raycast_params = RaycastParams.new();

			-- filtertype
			if self.whitelist ~= nil then raycast_params.FilterType = Enum.RaycastFilterType.Whitelist;
			elseif self.blacklist ~= nil then raycast_params.FilterType = Enum.RaycastFilterType.Blacklist; end
			
			-- ignorewater
			raycast_params.IgnoreWater = self.ignore_water;

			-- filterdescendantsinstances
			if self.whitelist ~= nil or self.blacklist ~= nil then raycast_params.FilterDescendantsInstances = self.whitelist or self.blacklist; end

			-- raycast
			local raycast;

			if gun_behavior then raycast = workspace:Raycast(self.origin, (self.target - self.origin).Unit * ((self.target - self.origin).Magnitude + 1), raycast_params);
			else raycast = workspace:Raycast(self.origin, self.target, raycast_params) end

			if visible ~= nil then
				coroutine.wrap(function ()
					local part = Instance.new("Part", workspace);
					local distance = (self.origin - raycast.Position).magnitude;
					
					part.Name = visible.name;
					part.Parent = visible.parent;
					part.Size = Vector3.new(visible.size, visible.size, distance);
					part.Color = visible.color;
					part.Material = visible.material;
					part.Transparency = visible.transparency;
					part.CFrame = CFrame.new((self.origin + raycast.Position) / 2, raycast.Position);
					part.Anchored = true;
					part.CanCollide = false;

					if visible.destroy ~= nil then
						wait(visible.destroy);
						part:Destroy();
					end
				end)();
			end

			return raycast;
		else
			-- error
			local message = "muta.lua : RayCast.cast() -> tried to cast ray but parameters were found nil";
			print(message);
		end

		return nil;
	end
}

return Raycast;
