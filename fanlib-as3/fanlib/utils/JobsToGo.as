package fanlib.utils
{
	public class JobsToGo
	{
		private var jobs:uint;
		private var goFunc:Function;
		private var _allJobsSet:Boolean = false; // in case 1st job finishes before setting 2nd, so 'goFunc' is called too early!
		
		/**
		 * @param _goFunc Function to call when all jobs are set
		 * @param _jobs Set an arbitrary initial number of unfinished jobs
		 */
		public function JobsToGo(_goFunc:Function, _jobs:uint = 0)
		{
			jobs = _jobs;
			goFunc = _goFunc;
		}
		
		public function newJob(dummy:* = undefined):* {
			++jobs;
			return dummy;
		}
		
		/**
		 * @param dummy
		 * @return True if all jobs are done and final function has been called!
		 */
		public function jobDone(dummy:* = undefined):Boolean {
			if ((--jobs === 0) && _allJobsSet) { // WARNING!!! 1st decrease 'jobs', 2nd check for '_allJobsSet'!!!
				goFunc();
				goFunc = null;
				return true; // a bit too much since we have the above line, but I am a bit too much anyway
			}
			return false;
		}

		/**
		 * Call this AFTER setting the initial list of jobs. If later new jobs are added, make sure old jobs are "closed" AFTERWARDS (by calling 'jobDone').
		 * <p>This is to prevent from calling the final function before all initial jobs are set, since the 1st job might finish IMMEDIATELY.</p>
		 * @return True if all jobs are done and final function has been called!
		 */
		public function allJobsSet():Boolean {
			_allJobsSet = true;
			++jobs;
			return jobDone();
		}
		public function areAllJobsSet():Boolean { return _allJobsSet; }

		public function get unfinishedJobs():uint {
			return jobs;
		}
	}
}