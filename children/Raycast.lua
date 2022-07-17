local Raycast = {
	origin = nil,
	target = nil,
	filter_type = nil,
	filter_content = nil,
	ignore_water = false,
	gun_behavior = false,
	part = false,
	part_params = {},

	build = function (self, origin: Vector3, target: Vector3, options: { filter: { ftype: string, content: {} }?, ignore_water: boolean?, gun_behavior: boolean?, part: { name: string?, parent: Instance?, color: Color3?, size: number?, transparency: number?, material: Enum.Material?, destroy: number? } | boolean? }?): {}
		-- optional params
		options = options or {};

		-- params
		self.origin = origin;
		self.target = target;
		self.ignore_water = options.ignore_water or false;
		self.gun_behavior = options.gun_behavior or false;
		
		if options.part then
			self.part = true;
			if options.part == true then options.part = {}; end
			self.part_params.name = options.part.name or "Part";
			self.part_params.parent = options.part.parent or workspace;
			self.part_params.color = options.part.color or Color3.new(163/255, 162/255, 165/255);
			self.part_params.size = options.part.size or 0.1;
			self.part_params.transparency = options.part.transparency or 0;
			self.part_params.material = options.part.material or Enum.Material.Plastic;
			self.part_params.destroy = options.part.destroy or false;
		end

		if options.filter then
			if options.filter.ftype == "blacklist" then self.filter_type = "blacklist";
			elseif options.filter.ftype == "whitelist" then self.filter_type = "whitelist";
			else self.filter_type = nil; end 
			
			self.filter_content = options.filter.content or nil;
		end
		
		-- return self
		return self;
	end,

	cast = function (self): RaycastResult | nil	
		-- creating raycast
		if self.origin ~= nil and self.target ~= nil then
			local raycast_params = RaycastParams.new();

			-- filtertype
			if self.filter_type == "blacklist" then raycast_params.FilterType = Enum.RaycastFilterType.Blacklist;
			elseif self.filter_type == "whitelist" then raycast_params.FilterType = Enum.RaycastFilterType.Whitelist; end
			
			-- ignorewater
			raycast_params.IgnoreWater = self.ignore_water;

			-- filterdescendantsinstances
			if self.filter_content then raycast_params.FilterDescendantsInstances = self.filter_content; end

			-- raycast
			local raycast;

			if self.gun_behavior then raycast = workspace:Raycast(self.origin, (self.target - self.origin).Unit * ((self.target - self.origin).Magnitude + 1), raycast_params);
			else raycast = workspace:Raycast(self.origin, self.target, raycast_params) end

			if self.part == true then
				coroutine.wrap(function ()
					if raycast then
						local part = Instance.new("Part", workspace);
						local distance = (self.origin - raycast.Position).magnitude;
						
						part.Name = self.part_params.name;
						part.Parent = self.part_params.parent;
						part.Color = self.part_params.color;
						part.Size = Vector3.new(self.part_params.size, self.part_params.size, distance);
						part.Transparency = self.part_params.transparency;
						part.Material = self.part_params.material;
						part.CFrame = CFrame.new((self.origin + raycast.Position) / 2, raycast.Position);
						part.Anchored = true;
						part.CanCollide = false;

						if self.part_params.destroy ~= false then
							wait(self.part_params.destroy);
							part:Destroy();
						end
					else
						-- error
						local message = "Raycast:cast() -> tried to cast ray but performed raycast was found nil";
						print(message);
					end
				end)();
			end

			return raycast;
		else
			-- error
			local message = "Raycast:cast() -> tried to cast ray but parameters were found nil";
			print(message);
		end

		return nil;
	end
}

return Raycast;
