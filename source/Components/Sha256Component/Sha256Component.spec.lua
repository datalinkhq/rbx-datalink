return function()
	local Sha256Component = require(script.Parent)()

	describe("Test the integrity of the SHA-256 algorithm with defaults", function()
		it("Should match the correct hash with no salt: 'Datalink-SDK Hash Demo!'", function()
			expect(Sha256Component:hash("Datalink-SDK Hash Demo!")).to.be.equal("495d5eebbc52abbe46e87e4c12d2890bb6c74e96f90c2c7e4a9380cc0079afc1")
		end)

		it("Should match the correct hash with salt: 'Datalink-SDK Hash Demo!'", function()
			expect(Sha256Component:hash("Datalink-SDK Hash Demo!", "Test Salt!")).to.be.equal("6e4fea46b16098dcdf869491f4f996f0aaf729fa99b00bd018e37c1ad6a17ede")
		end)
	end)
end