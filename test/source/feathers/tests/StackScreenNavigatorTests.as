package feathers.tests
{
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;

	import flexunit.framework.Assert;

	import starling.display.Quad;
	import starling.events.Event;

	public class StackScreenNavigatorTests
	{
		private static const SCREEN_A_ID:String = "a";
		private static const SCREEN_B_ID:String = "b";
		private static const SCREEN_C_ID:String = "c";
		
		private static const EVENT_PUSH_SCREEN_B:String = "pushScreenB";
		private static const EVENT_PUSH_SCREEN_C:String = "pushScreenC";
		private static const EVENT_REPLACE_WITH_SCREEN_C:String = "replaceWithScreenC";
		private static const EVENT_POP_SCREEN:String = "popScreen";
		private static const EVENT_POP_TO_ROOT_SCREEN:String = "popToRootScreen";
		private static const EVENT_CALL_FUNCTION:String = "callFunction";
		
		private var _navigator:StackScreenNavigator;
		private var _functionWasCalled:Boolean = false;

		[Before]
		public function prepare():void
		{
			this._navigator = new StackScreenNavigator();
			TestFeathers.starlingRoot.addChild(this._navigator);
			this._navigator.validate();
			
			this._functionWasCalled = false;
		}

		[After]
		public function cleanup():void
		{
			this._navigator.removeFromParent(true);
			this._navigator = null;

			Assert.assertStrictlyEquals("Child not removed from Starling root on cleanup.", 0, TestFeathers.starlingRoot.numChildren);
		}

		[Test]
		public function testHasScreenWhenNotAdded():void
		{
			Assert.assertFalse("hasScreen() incorrectly returned true for a screen that was not added", this._navigator.hasScreen(SCREEN_A_ID));
		}

		[Test]
		public function testHasScreen():void
		{
			this.addScreenA();
			Assert.assertTrue("hasScreen() incorrectly returned false for a screen that was added", this._navigator.hasScreen(SCREEN_A_ID));
		}

		[Test]
		public function testStateWithEmptyStack():void
		{
			Assert.assertNull("activeScreen returned incorrect value for empty stack", this._navigator.activeScreen);
			Assert.assertNull("activeScreenID returned incorrect value for empty stack", this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for empty stack", 0, this._navigator.stackCount);
		}

		[Test]
		public function testSetRootScreenID():void
		{
			this.addScreenA();
			this._navigator.rootScreenID = SCREEN_A_ID;
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack with only root screen", this._navigator.getScreen(SCREEN_A_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack with only root screen", SCREEN_A_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack with only root screen", 1, this._navigator.stackCount);
		}

		[Test]
		public function testPushScreen():void
		{
			this.addScreenA();
			this.addScreenB();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.pushScreen(SCREEN_B_ID);
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after pushScreen()", this._navigator.getScreen(SCREEN_B_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after pushScreen()", SCREEN_B_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after pushScreen()", 2, this._navigator.stackCount);
		}

		[Test]
		public function testReplaceScreen():void
		{
			this.addScreenA();
			this.addScreenB();
			this.addScreenC();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.pushScreen(SCREEN_B_ID);
			this._navigator.replaceScreen(SCREEN_C_ID);
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after replaceScreen()", this._navigator.getScreen(SCREEN_C_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after replaceScreen()", SCREEN_C_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after replaceScreen()", 2, this._navigator.stackCount);
		}

		[Test]
		public function testPopScreen():void
		{
			this.addScreenA();
			this.addScreenB();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.pushScreen(SCREEN_B_ID);
			this._navigator.popScreen();
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after popScreen()", this._navigator.getScreen(SCREEN_A_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after popScreen()", SCREEN_A_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after popScreen()", 1, this._navigator.stackCount);
		}

		[Test]
		public function testPopToRootScreen():void
		{
			this.addScreenA();
			this.addScreenB();
			this.addScreenC();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.pushScreen(SCREEN_B_ID);
			this._navigator.pushScreen(SCREEN_C_ID);
			this._navigator.popToRootScreen();
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after popToRootScreen()", this._navigator.getScreen(SCREEN_A_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after popToRootScreen()", SCREEN_A_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after popToRootScreen()", 1, this._navigator.stackCount);
		}

		[Test]
		public function testPushScreenWithEvent():void
		{
			this.addScreenA();
			this.addScreenB();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.activeScreen.dispatchEventWith(EVENT_PUSH_SCREEN_B);
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after push screen with event", this._navigator.getScreen(SCREEN_B_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after push screen with event", SCREEN_B_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack with after push screen with event", 2, this._navigator.stackCount);
		}

		[Test]
		public function testReplaceScreenWithEvent():void
		{
			this.addScreenA();
			this.addScreenB();
			this.addScreenC();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.activeScreen.dispatchEventWith(EVENT_PUSH_SCREEN_B);
			this._navigator.activeScreen.dispatchEventWith(EVENT_REPLACE_WITH_SCREEN_C);
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after replace screen with event", this._navigator.getScreen(SCREEN_C_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after replace screen with event", SCREEN_C_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after replace screen with event", 2, this._navigator.stackCount);
		}

		[Test]
		public function testPopScreenWithEvent():void
		{
			this.addScreenA();
			this.addScreenB();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.activeScreen.dispatchEventWith(EVENT_PUSH_SCREEN_B);
			this._navigator.activeScreen.dispatchEventWith(EVENT_POP_SCREEN);
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after pop screen with event", this._navigator.getScreen(SCREEN_A_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after pop screen with event", SCREEN_A_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after pop screen with event", 1, this._navigator.stackCount);
		}

		[Test]
		public function testPopToRootScreenWithEvent():void
		{
			this.addScreenA();
			this.addScreenB();
			this.addScreenC();
			this._navigator.rootScreenID = SCREEN_A_ID;
			this._navigator.activeScreen.dispatchEventWith(EVENT_PUSH_SCREEN_B);
			this._navigator.activeScreen.dispatchEventWith(EVENT_PUSH_SCREEN_C);
			this._navigator.activeScreen.dispatchEventWith(EVENT_POP_TO_ROOT_SCREEN);
			Assert.assertStrictlyEquals("activeScreen returned incorrect value for stack after pop to root with event", this._navigator.getScreen(SCREEN_A_ID).screen, this._navigator.activeScreen);
			Assert.assertStrictlyEquals("activeScreenID returned incorrect value for stack after pop to root with event", SCREEN_A_ID, this._navigator.activeScreenID);
			Assert.assertStrictlyEquals("stackCount returned incorrect value for stack after pop to root with event", 1, this._navigator.stackCount);
		}

		[Test]
		public function testScreenWithEventAndMethodWithSameName():void
		{
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(ScreenWithEventAndMethodWithSameName);
			item.setScreenIDForPushEvent(EVENT_PUSH_SCREEN_B, SCREEN_B_ID);
			item.setScreenIDForReplaceEvent(EVENT_REPLACE_WITH_SCREEN_C, SCREEN_C_ID);
			item.addPopEvent(EVENT_POP_SCREEN);
			item.addPopToRootEvent(EVENT_POP_TO_ROOT_SCREEN);
			this._navigator.addScreen(SCREEN_A_ID, item);
			this._navigator.rootScreenID = SCREEN_A_ID;
		}
		
		private function addScreenA():void
		{
			var screen:Quad = new Quad(10, 10, 0xff00ff);
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screen);
			item.setScreenIDForPushEvent(EVENT_PUSH_SCREEN_B, SCREEN_B_ID);
			item.setFunctionForPushEvent(EVENT_CALL_FUNCTION, eventFunction);
			this._navigator.addScreen(SCREEN_A_ID, item);
		}

		private function addScreenB():void
		{
			var screen:Quad = new Quad(10, 10, 0xffff00);
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screen);
			item.setScreenIDForPushEvent(EVENT_PUSH_SCREEN_C, SCREEN_C_ID);
			item.setScreenIDForReplaceEvent(EVENT_REPLACE_WITH_SCREEN_C, SCREEN_C_ID);
			item.addPopEvent(EVENT_POP_SCREEN);
			this._navigator.addScreen(SCREEN_B_ID, item);
		}

		private function addScreenC():void
		{
			var screen:Quad = new Quad(10, 10, 0x00ffff);
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screen);
			item.addPopEvent(EVENT_POP_SCREEN);
			item.addPopToRootEvent(EVENT_POP_TO_ROOT_SCREEN);
			this._navigator.addScreen(SCREEN_C_ID, item);
		}

		private function eventFunction():void
		{
			this._functionWasCalled = true;
		}
	}
}

import starling.display.Quad;

class ScreenWithEventAndMethodWithSameName extends Quad
{
	public function ScreenWithEventAndMethodWithSameName()
	{
		super(10, 10, 0xff00ff);
	}

	public function pushScreenB():void {}
	public function replaceWithScreenC():void {}
	public function popScreen():void {}
	public function popToRootScreen():void {}
}
